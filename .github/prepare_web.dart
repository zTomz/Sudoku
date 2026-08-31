import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final directory = Directory(
    arguments.isEmpty ? 'build/web' : arguments.single,
  );
  if (!File('${directory.path}/main.dart.js').existsSync()) {
    throw StateError(
      'Run flutter build web --release --no-web-resources-cdn first.',
    );
  }
  await File('${directory.path}/offline_bootstrap.js').writeAsString("""
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register(new URL('sudoku-sw.js', document.baseURI), {
      scope: new URL('.', document.baseURI).pathname,
      updateViaCache: 'none'
    }).catch((error) => console.warn('Offline cache unavailable', error));
  });
}
""");
  await File('${directory.path}/.nojekyll').writeAsString('');
  final files =
      directory
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                !file.path.endsWith('sudoku-sw.js') &&
                !file.path.endsWith('.map'),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  var hash = 1;
  final resources = <String>[];
  for (final file in files) {
    final relative = file.path
        .substring(directory.path.length + 1)
        .replaceAll('\\', '/');
    if (relative.startsWith('.') ||
        relative == '_headers' ||
        relative.endsWith('.symbols') ||
        (relative.startsWith('canvaskit/') &&
            relative != 'canvaskit/canvaskit.js' &&
            relative != 'canvaskit/canvaskit.wasm')) {
      continue;
    }
    resources.add(relative);
    for (final byte in [
      ...utf8.encode(relative),
      ...await file.readAsBytes(),
    ]) {
      hash = (hash * 31 + byte) % 2147483647;
    }
  }
  final worker =
      """
const PREFIX = 'sudoku-' + encodeURIComponent(self.registration.scope) + '-';
const CACHE = PREFIX + '$hash';
const RESOURCES = ${jsonEncode(resources)};
const urls = new Set(RESOURCES.map(path => new URL(path, self.registration.scope).href));
const indexUrl = new URL('index.html', self.registration.scope).href;

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(CACHE);
    try {
      await cache.addAll([...urls].map(url => new Request(url, { cache: 'reload' })));
    } catch (error) {
      await caches.delete(CACHE);
      throw error;
    }
  })());
});
self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    for (const name of await caches.keys()) {
      if (name.startsWith(PREFIX) && name !== CACHE) await caches.delete(name);
    }
    await self.clients.claim();
  })());
});
self.addEventListener('fetch', event => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  const scope = new URL(self.registration.scope);
  if (url.origin !== scope.origin || !url.pathname.startsWith(scope.pathname)) return;
  url.search = '';
  url.hash = '';
  const navigation = request.mode === 'navigate';
  if (!navigation && !urls.has(url.href)) return;
  event.respondWith((async () => {
    const cache = await caches.open(CACHE);
    const saved = await cache.match(navigation ? indexUrl : url.href);
    return saved || fetch(request);
  })());
});
""";
  await File('${directory.path}/sudoku-sw.js').writeAsString(worker);
  stdout.writeln(
    'Offline cache prepared: ${resources.length} resources, revision $hash.',
  );
}
