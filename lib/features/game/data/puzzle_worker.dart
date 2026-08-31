import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'generation_job.dart';

@JS('self')
external DedicatedWorkerGlobalScope get worker;

void main() {
  worker.onmessage = ((MessageEvent event) {
    unawaited(_generate(event));
  }).toJS;
}

Future<void> _generate(MessageEvent event) async {
  try {
    final request = GenerationRequest.fromJson(
      jsonDecode((event.data as JSString).toDart) as Map<String, Object?>,
    );
    final puzzle = await request.run();
    worker.postMessage(jsonEncode(puzzle.toJson()).toJS);
  } catch (error) {
    worker.postMessage(jsonEncode({'error': error.toString()}).toJS);
  }
}
