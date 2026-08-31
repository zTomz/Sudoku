import 'dart:isolate';

import '../domain/puzzle.dart';
import 'generation_job.dart';

GenerationJob generatePuzzle(GenerationRequest request) {
  final job = GenerationJob();
  final port = ReceivePort();
  Isolate? isolate;
  job.attach(() {
    isolate?.kill(priority: Isolate.immediate);
    port.close();
  });
  port.listen((Object? message) {
    if (message is Puzzle) {
      job.succeed(message);
    } else {
      job.fail(StateError('Puzzle worker failed: $message'));
    }
  });
  Isolate.spawn(
    _work,
    (request, port.sendPort),
    onError: port.sendPort,
    onExit: port.sendPort,
    errorsAreFatal: true,
  ).then((worker) {
    isolate = worker;
    if (job.completed) worker.kill(priority: Isolate.immediate);
  }, onError: (Object error, StackTrace stack) => job.fail(error));
  return job;
}

Future<void> _work((GenerationRequest, SendPort) message) async {
  message.$2.send(await message.$1.run());
}
