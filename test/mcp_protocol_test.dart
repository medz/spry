import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spry/src/mcp/mcp_protocol.dart';
import 'package:test/test.dart';

void main() {
  group('JsonRpcRequest', () {
    test('rejects invalid request envelopes with a protocol error', () {
      for (final value in [
        <String, dynamic>{},
        {'jsonrpc': '2.0', 'method': 12},
        {'jsonrpc': '1.0', 'method': 'ping'},
        {'jsonrpc': '2.0', 'method': 'ping', 'id': true},
      ]) {
        expect(
          () => JsonRpcRequest.fromJson(value),
          throwsA(
            isA<JsonRpcError>().having(
              (e) => e.code,
              'code',
              JsonRpcErrors.invalidRequest,
            ),
          ),
        );
      }
    });

    test('rejects invalid named MCP params with a protocol error', () {
      expect(
        () => JsonRpcRequest.fromJson({
          'jsonrpc': '2.0',
          'id': 7,
          'method': 'tools/call',
          'params': 12,
        }),
        throwsA(
          isA<JsonRpcError>()
              .having((e) => e.code, 'code', JsonRpcErrors.invalidParams)
              .having((e) => e.id, 'id', 7),
        ),
      );
    });

    test('parses a request with params', () {
      final json = {
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'tools/call',
        'params': {'name': 'spry.list_routes'},
      };

      final request = JsonRpcRequest.fromJson(json);

      expect(request.jsonrpc, '2.0');
      expect(request.id, 1);
      expect(request.method, 'tools/call');
      expect(request.params, {'name': 'spry.list_routes'});
    });

    test('parses a request without params', () {
      final json = {'jsonrpc': '2.0', 'id': 2, 'method': 'tools/list'};

      final request = JsonRpcRequest.fromJson(json);

      expect(request.params, isNull);
    });

    test('parses a notification (omitted id)', () {
      final json = {'jsonrpc': '2.0', 'method': 'notifications/initialized'};

      final request = JsonRpcRequest.fromJson(json);

      expect(request.id, isNull);
      expect(request.isNotification, isTrue);
      expect(request.method, 'notifications/initialized');
    });

    test('explicit null IDs are requests and preserve their IDs', () {
      final request = JsonRpcRequest.fromJson({
        'jsonrpc': '2.0',
        'id': null,
        'method': 'ping',
      });
      expect(request.isNotification, isFalse);
      expect(request.toJson().containsKey('id'), isTrue);
      final notification = JsonRpcRequest.fromJson({
        'jsonrpc': '2.0',
        'method': 'ping',
      });
      expect(notification.toJson().containsKey('id'), isFalse);
    });

    test('serializes to JSON-compatible map', () {
      final request = const JsonRpcRequest(
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {'protocolVersion': '2024-11-05'},
      );

      final map = request.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['method'], 'initialize');
      expect(map['params'], {'protocolVersion': '2024-11-05'});
    });

    test('serializes without params when null', () {
      final request = const JsonRpcRequest(
        jsonrpc: '2.0',
        id: 1,
        method: 'tools/list',
      );

      final map = request.toJson();

      expect(map.containsKey('params'), isFalse);
    });
  });

  test('stdio recovers from malformed requests and continues to ping', () async {
    final root = Directory('test/fixtures/generator/no_hooks').absolute.path;
    final process = await Process.start(Platform.resolvedExecutable, [
      'run',
      'bin/spry.dart',
      'mcp',
      '--root',
      root,
    ]);
    addTearDown(process.kill);
    final output = StreamIterator(
      process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
    );
    addTearDown(output.cancel);
    final errors = process.stderr.transform(utf8.decoder).join();
    // Cold CLI compilation competes with other integration tests in CI.
    // Allow startup its own budget before checking protocol recovery.
    process.stdin.writeln('{"jsonrpc":"2.0","method":"ping","id":0}');
    expect(
      await output.moveNext().timeout(const Duration(seconds: 60)),
      isTrue,
    );
    expect(jsonDecode(output.current), {
      'jsonrpc': '2.0',
      'id': 0,
      'result': <String, dynamic>{},
    });
    for (final line in [
      '{"jsonrpc":"2.0","method":"notifications/initialized","params":12}',
      '{',
      '42',
      '{"jsonrpc":"2.0","id":1}',
      '{"jsonrpc":"2.0","method":5,"id":2}',
      '{"jsonrpc":"2.0","method":"tools/call","params":12,"id":3}',
      '{"jsonrpc":"2.0","method":"tools/call","params":{"name":12},"id":4}',
      '{"jsonrpc":"2.0","method":"tools/call","params":{"name":"spry.explain_route","arguments":{"method":12}},"id":5}',
      '{"jsonrpc":"2.0","method":"ping"}',
      '{"jsonrpc":"2.0","method":"ping","id":null}',
      '{"jsonrpc":"2.0","method":"ping","id":6}',
    ]) {
      process.stdin.writeln(line);
    }
    await process.stdin.close();
    final responses = <Map>[];
    while (await output.moveNext().timeout(const Duration(seconds: 20))) {
      responses.add(jsonDecode(output.current) as Map);
    }
    expect(
      await process.exitCode.timeout(const Duration(seconds: 20)),
      0,
      reason: await errors,
    );
    expect(responses, hasLength(9));
    expect(responses.take(5).map((e) => e['error']['code']), [
      -32700,
      -32600,
      -32600,
      -32600,
      -32602,
    ]);
    expect(responses[5]['result']['isError'], isTrue);
    expect(responses[6]['result']['isError'], isTrue);
    expect(responses[7]['id'], isNull);
    expect(responses[7]['result'], isEmpty);
    expect(responses.last['id'], 6);
    expect(responses.last['result'], isEmpty);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test(
    'stdio contains unexpected tool failures and continues to ping',
    () async {
      final base = Directory('.dart_tool/test_tmp');
      await base.create(recursive: true);
      final root = await base.createTemp('spry_mcp_failure_');
      addTearDown(() => root.delete(recursive: true));
      final entry = File('${root.path}/main.dart');
      await entry.writeAsString('''import 'dart:io';
import 'package:spry/src/builder/config.dart';
import 'package:spry/src/mcp/mcp_server.dart';
Future<void> main() => IOOverrides.runZoned(
  () => runMcpServer(config: BuildConfig(rootDir: Directory.current.path), entries: []),
  statSync: (_) => throw const FileSystemException('asset probe failed'),
);
''');
      final process = await Process.start(Platform.resolvedExecutable, [
        entry.absolute.path,
      ]);
      addTearDown(process.kill);
      final output = process.stdout.transform(utf8.decoder).join();
      final errors = process.stderr.transform(utf8.decoder).join();
      process.stdin.writeln(
        jsonEncode({
          'jsonrpc': '2.0',
          'id': 1,
          'method': 'tools/call',
          'params': {
            'name': 'spry.explain_route',
            'arguments': {'method': 'GET', 'path': '/'},
          },
        }),
      );
      process.stdin.writeln('{"jsonrpc":"2.0","id":2,"method":"ping"}');
      await process.stdin.close();
      expect(
        await process.exitCode.timeout(const Duration(seconds: 60)),
        0,
        reason: await errors,
      );
      final responses = (await output)
          .trim()
          .split('\n')
          .map((line) => jsonDecode(line) as Map)
          .toList();
      expect(responses, hasLength(2));
      expect(responses.first['result']['isError'], isTrue);
      expect(
        responses.first['result']['content'][0]['text'],
        contains('asset probe failed'),
      );
      expect(responses.last['id'], 2);
      expect(responses.last['result'], isEmpty);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'standalone stdio refreshes edited project state and recovers invalid config',
    () async {
      final base = Directory('.dart_tool/test_tmp');
      await base.create(recursive: true);
      final root = await base.createTemp('spry_mcp_refresh_');
      addTearDown(() => root.delete(recursive: true));
      await Directory('${root.path}/routes').create();
      await File(
        'test/fixtures/generator/no_hooks/routes/index.dart',
      ).copy('${root.path}/routes/index.dart');
      final process = await Process.start(Platform.resolvedExecutable, [
        'run',
        'bin/spry.dart',
        'mcp',
        '--root',
        root.absolute.path,
      ]);
      addTearDown(process.kill);
      final responses = StreamIterator(
        process.stdout.transform(utf8.decoder).transform(const LineSplitter()),
      );
      addTearDown(responses.cancel);
      final errors = process.stderr.transform(utf8.decoder).join();
      Future<Map> call(int id, String tool) async {
        process.stdin.writeln(
          jsonEncode({
            'jsonrpc': '2.0',
            'id': id,
            'method': 'tools/call',
            'params': {'name': tool},
          }),
        );
        expect(
          await responses.moveNext().timeout(
            Duration(seconds: id == 1 ? 60 : 20),
          ),
          isTrue,
        );
        return jsonDecode(responses.current) as Map;
      }

      Map content(Map response) =>
          jsonDecode(response['result']['content'][0]['text'] as String) as Map;
      final initial = content(await call(1, 'spry.get_project_info'));
      expect(initial['route_count'], 1);
      expect(initial['build'], {
        'source': 'inspection',
        'latest_attempt': {'status': 'unknown'},
        'last_successful_generation': null,
        'disk_state': 'unknown',
      });
      await File(
        '${root.path}/routes/index.dart',
      ).copy('${root.path}/routes/added.get.dart');
      expect(content(await call(2, 'spry.get_project_info'))['route_count'], 2);
      final config = File('${root.path}/spry.config.dart');
      await config.writeAsString("void main() { print('{\"port\":4567}'); }\n");
      expect(content(await call(3, 'spry.get_config'))['port'], 4567);
      await config.writeAsString('this is not valid Dart');
      expect((await call(4, 'spry.get_config'))['error']['code'], -32603);
      await config.writeAsString("void main() { print('{\"port\":5678}'); }\n");
      expect(content(await call(5, 'spry.get_config'))['port'], 5678);
      await File('${root.path}/routes/added.get.dart').delete();
      expect(content(await call(6, 'spry.get_project_info'))['route_count'], 1);
      await process.stdin.close();
      expect(
        await process.exitCode.timeout(const Duration(seconds: 20)),
        0,
        reason: await errors,
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  group('JsonRpcResponse', () {
    test('result factory creates success response', () {
      final response = JsonRpcResponse.result(1, {'key': 'value'});

      expect(response.jsonrpc, '2.0');
      expect(response.id, 1);
      expect(response.result, {'key': 'value'});
    });

    test('serializes success response', () {
      final response = JsonRpcResponse.result(1, {'tools': []});

      final map = response.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['result'], {'tools': []});
      expect(map.containsKey('error'), isFalse);
    });
  });

  group('JsonRpcError', () {
    test('methodNotFound factory creates error', () {
      final error = JsonRpcError.methodNotFound(1, 'foo');

      expect(error.jsonrpc, '2.0');
      expect(error.id, 1);
      expect(error.code, JsonRpcErrors.methodNotFound);
      expect(error.message, 'Method not found: foo');
    });

    test('invalidParams factory creates error', () {
      final error = JsonRpcError.invalidParams(2, 'Missing tool name');

      expect(error.code, JsonRpcErrors.invalidParams);
      expect(error.id, 2);
      expect(error.message, 'Missing tool name');
    });

    test('parseError factory creates error with null id', () {
      final error = JsonRpcError.parseError(message: 'Bad JSON');

      expect(error.code, JsonRpcErrors.parseError);
      expect(error.id, isNull);
      expect(error.message, 'Bad JSON');
    });

    test('internalError factory creates error', () {
      final error = JsonRpcError.internalError(3, 'Something broke');

      expect(error.code, JsonRpcErrors.internalError);
      expect(error.id, 3);
      expect(error.message, 'Something broke');
    });

    test('serializes to JSON-compatible map', () {
      final error = JsonRpcError.methodNotFound(1, 'test');

      final map = error.toJson();

      expect(map['jsonrpc'], '2.0');
      expect(map['id'], 1);
      expect(map['error'], {
        'code': JsonRpcErrors.methodNotFound,
        'message': 'Method not found: test',
      });
    });

    test('serializes with optional data', () {
      final error = JsonRpcError(
        jsonrpc: '2.0',
        id: 1,
        code: -32603,
        message: 'Internal error',
        data: {'detail': 'stack trace here'},
      );

      final map = error.toJson();

      expect(map['error']['data'], {'detail': 'stack trace here'});
    });
  });

  group('JsonRpcErrors', () {
    test('defines standard error codes', () {
      expect(JsonRpcErrors.parseError, -32700);
      expect(JsonRpcErrors.invalidRequest, -32600);
      expect(JsonRpcErrors.methodNotFound, -32601);
      expect(JsonRpcErrors.invalidParams, -32602);
      expect(JsonRpcErrors.internalError, -32603);
    });
  });

  group('MCP protocol constants', () {
    test('jsonRpcVersion is 2.0', () {
      expect(jsonRpcVersion, '2.0');
    });

    test('latestProtocolVersion is 2025-06-18', () {
      expect(latestProtocolVersion, '2025-06-18');
    });
  });
}
