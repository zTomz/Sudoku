const test = require("node:test");
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const root = path.resolve(__dirname, "../build/web");
const source = fs.readFileSync(path.join(root, "sudoku-sw.js"), "utf8");

function harness(scope, failInstall = false) {
  const hooks = new Map();
  const stores = new Map();
  const requested = [];
  const prefix = "sudoku-" + encodeURIComponent(scope) + "-";
  stores.set(prefix + "previous", new Map());
  stores.set("another-app", new Map());
  const caches = {
    open: async (name) => {
      if (!stores.has(name)) stores.set(name, new Map());
      const entries = stores.get(name);
      return {
        addAll: async (requests) => {
          if (failInstall) throw new Error("offline");
          for (const request of requests) {
            assert.ok(request.url.startsWith(scope));
            const relative = decodeURIComponent(request.url.substring(scope.length));
            assert.ok(fs.existsSync(path.join(root, relative)), relative);
            requested.push(relative);
            entries.set(request.url, { cached: relative });
          }
        },
        match: async (url) => entries.get(url),
      };
    },
    keys: async () => [...stores.keys()],
    delete: async (name) => stores.delete(name),
  };
  vm.runInNewContext(source, {
    self: { registration: { scope }, clients: { claim: async () => {} },
      addEventListener: (name, callback) => hooks.set(name, callback) },
    caches, URL, Request,
    fetch: async (request) => ({ network: request.url }),
  });
  async function lifecycle(name) {
    let pending;
    hooks.get(name)({ waitUntil: (promise) => { pending = promise; } });
    await pending;
  }
  async function request(url, mode = "cors", method = "GET") {
    let response;
    hooks.get("fetch")({ request: { url, mode, method },
      respondWith: (promise) => { response = promise; } });
    return response ? await response : undefined;
  }
  return { lifecycle, request, requested, stores, prefix };
}

for (const scope of ["https://example.test/", "https://example.test/sudoku/"]) {
  test("offline asset and navigation routing at " + scope, async () => {
    const h = harness(scope);
    await h.lifecycle("install");
    assert.ok(h.requested.includes("main.dart.js"));
    assert.ok(h.requested.includes("assets/assets/fonts/GoogleSans.ttf"));
    assert.ok(h.requested.includes("canvaskit/canvaskit.wasm"));
    assert.ok(!h.requested.includes("_headers"));
    assert.deepEqual(await h.request(scope + "main.dart.js?v=1"), { cached: "main.dart.js" });
    assert.deepEqual(await h.request(scope + "calendar", "navigate"), { cached: "index.html" });
    assert.equal(await h.request("https://outside.test/game"), undefined);
    assert.equal(await h.request(scope + "unknown.json"), undefined);
    assert.equal(await h.request(scope + "main.dart.js", "cors", "POST"), undefined);
    await h.lifecycle("activate");
    assert.equal(h.stores.has(h.prefix + "previous"), false);
    assert.equal(h.stores.has("another-app"), true);
  });
}

test("failed precache is not activated and leaves other caches alone", async () => {
  const h = harness("https://example.test/sudoku/", true);
  await assert.rejects(h.lifecycle("install"), /offline/);
  assert.deepEqual([...h.stores.keys()], [h.prefix + "previous", "another-app"]);
});
