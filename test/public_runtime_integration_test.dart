import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:spry/config.dart';
import 'package:test/test.dart';

void main() {
  for (final target in [BuildTarget.vm, BuildTarget.node]) {
    test('generated ${target.name} server serves public GET and HEAD', () async {
      final base = Directory(p.absolute('.dart_tool', 'test_tmp'));
      await base.create(recursive: true);
      final root = await base.createTemp('public_runtime_');
      addTearDown(() => root.delete(recursive: true));
      await Directory(p.join(root.path, 'routes')).create();
      final public = Directory(p.join(root.path, 'public'));
      await public.create();
      await File(p.join(public.path, 'hello.txt')).writeAsString('hello');
      final reservation = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        0,
      );
      final port = reservation.port;
      await reservation.close();
      await File(p.join(root.path, 'spry.config.dart')).writeAsString(
        "import 'dart:convert';\nvoid main() => print(${jsonEncode(jsonEncode({'target': target.name, 'host': '127.0.0.1', 'port': port}))});\n",
      );
      final build = await Process.run(Platform.resolvedExecutable, [
        p.absolute('bin', 'spry.dart'),
        'build',
      ], workingDirectory: root.path);
      expect(build.exitCode, 0, reason: '${build.stdout}\n${build.stderr}');
      final process = await Process.start(
        target == BuildTarget.vm ? Platform.resolvedExecutable : 'node',
        [
          target == BuildTarget.vm
              ? '.spry/src/main.dart'
              : '.spry/node/index.cjs',
        ],
        workingDirectory: root.path,
      );
      final output = StringBuffer();
      final stdout = process.stdout
          .transform(utf8.decoder)
          .listen(output.write);
      final stderr = process.stderr
          .transform(utf8.decoder)
          .listen(output.write);
      var exited = false;
      unawaited(process.exitCode.then((_) => exited = true));
      var stopped = false;
      Future<void> stopServer() async {
        if (stopped) return;
        process.kill();
        await process.exitCode.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            process.kill(ProcessSignal.sigkill);
            return process.exitCode;
          },
        );
        await stdout.cancel();
        await stderr.cancel();
        stopped = true;
      }

      addTearDown(stopServer);
      final deadline = DateTime.now().add(const Duration(seconds: 60));
      while (true) {
        if (exited) fail('Server exited before listening: $output');
        try {
          final socket = await Socket.connect(
            '127.0.0.1',
            port,
            timeout: const Duration(milliseconds: 250),
          );
          socket.destroy();
          break;
        } on SocketException {
          if (DateTime.now().isAfter(deadline)) {
            fail('Server startup timeout: $output');
          }
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
      final client = HttpClient();
      addTearDown(() => client.close(force: true));
      for (final method in ['GET', 'HEAD']) {
        final request = await client.openUrl(
          method,
          Uri.parse('http://127.0.0.1:$port/hello.txt'),
        );
        final response = await request.close();
        final responseBody = await utf8.decoder.bind(response).join();
        expect(
          response.statusCode,
          200,
          reason: '$method: $responseBody\n$output',
        );
        expect(
          response.headers.value('content-type'),
          'text/plain; charset=utf-8',
        );
        expect(response.headers.value('content-length'), '5');
        expect(responseBody, method == 'GET' ? 'hello' : '');
      }
      final missing = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/missing.txt'),
      );
      final response = await missing.close();
      expect(response.statusCode, 404);
      await response.drain<void>();
      client.close(force: true);
      await stopServer();
      // The owned child must release its listener, including after file responses.
      final released = await ServerSocket.bind(
        InternetAddress.loopbackIPv4,
        port,
      );
      await released.close();
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
}
