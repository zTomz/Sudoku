const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { Worker } = require('node:worker_threads');

const workerPath = path.resolve(process.env.SUDOKU_WORKER_PATH || 'build/web/sudoku_worker.js');
const fixturesPath = process.env.SUDOKU_FIXTURES_PATH;

// Run the real compiled Dart worker in another thread. Only the browser
// message transport is adapted; generation and serialization are unchanged.
async function request(t, data) {
  const worker = new Worker(`
    const { parentPort, workerData } = require('node:worker_threads');
    globalThis.self = globalThis;
    globalThis.postMessage = message => parentPort.postMessage(message);
    require(workerData);
    parentPort.on('message', data => globalThis.onmessage({ data }));
  `, { eval: true, workerData: workerPath });
  t.after(() => worker.terminate());
  return await new Promise((resolve, reject) => {
    worker.once('error', reject);
    worker.once('message', message => {
      try { resolve(JSON.parse(message)); } catch (error) { reject(error); }
    });
    worker.postMessage(data);
  });
}

test('compiled worker reports malformed requests', { timeout: 10000 }, async t => {
  const response = await request(t, '{');
  assert.equal(typeof response.error, 'string');
});

test('compiled worker generates and rates all tiers and daily puzzles', { timeout: 60000 }, async t => {
  const fixtures = fixturesPath ? JSON.parse(fs.readFileSync(fixturesPath, 'utf8').replace(/^\uFEFF/, '')) : null;
  for (const difficulty of ['easy', 'medium', 'hard', 'daily']) {
    const daily = difficulty === 'daily';
    const response = await request(t, JSON.stringify({
      seed: daily ? 20260831 : 17,
      difficulty: daily ? 'medium' : difficulty,
      dailyDate: daily ? '2026-08-31' : null,
    }));
    assert.equal(response.error, undefined);
    assert.equal(response.givens.length, 81);
    assert.equal(response.difficulty, daily ? 'medium' : difficulty);
    assert.ok(response.rating.techniqueCost > 0);
    assert.ok(response.rating.steps >= response.givens.filter(n => n === 0).length);
    for (let c = 0; c < 81; c++) {
      if (response.givens[c]) assert.equal(response.givens[c], response.solution[c]);
    }
    for (let u = 0; u < 9; u++) {
      for (const cells of [
        Array.from({length: 9}, (_, n) => u * 9 + n),
        Array.from({length: 9}, (_, n) => n * 9 + u),
        Array.from({length: 9}, (_, n) => (Math.floor(u / 3) * 3 + Math.floor(n / 3)) * 9 + (u % 3) * 3 + n % 3),
      ]) assert.deepEqual(cells.map(c => response.solution[c]).sort(), [1,2,3,4,5,6,7,8,9]);
    }
    if (fixtures) {
      const reference = fixtures.find(p => p.id === response.id);
      assert.ok(reference, response.id);
      const {steps, ...puzzle} = reference;
      assert.deepEqual(response, puzzle);
    }
  }
});
