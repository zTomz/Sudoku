import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart';

import '../domain/puzzle.dart';
import 'generation_job.dart';

GenerationJob generatePuzzle(GenerationRequest request) {
  final job = GenerationJob();
  try {
    final worker = Worker(
      Uri.parse(document.baseURI).resolve('sudoku_worker.js').toString().toJS,
    );
    job.attach(() => worker.terminate());
    worker.onmessage = ((MessageEvent event) {
      try {
        final json =
            jsonDecode((event.data as JSString).toDart) as Map<String, Object?>;
        if (json['error'] case final String error) {
          job.fail(StateError(error));
        } else {
          job.succeed(Puzzle.fromJson(json));
        }
      } catch (error) {
        job.fail(error);
      }
    }).toJS;
    worker.onerror = ((Event event) {
      job.fail(StateError('Unable to load or run the puzzle worker'));
    }).toJS;
    worker.onmessageerror = ((MessageEvent event) {
      job.fail(StateError('Invalid puzzle worker message'));
    }).toJS;
    worker.postMessage(jsonEncode(request.toJson()).toJS);
  } catch (error) {
    job.fail(error);
  }
  return job;
}
