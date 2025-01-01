import 'package:spry/server.dart';
import 'package:test/test.dart';

void main() {
  late Server server;

  tearDown(() async {
    await server.ready();
    await server.close(force: true);
  });

  group('Options', () {
    test('should create a server with default options', () {
      fetch(_, __) => throw Error();
      server = serve(fetch: fetch);
      expect(server.options.hostname, isNull);
      expect(server.options.port, isNull);
      expect(server.options.reusePort, isTrue);
      expect(server.options.fetch, fetch);
    });

    test('should create a server with custom options', () {
      fetch(_, __) => throw Error();
      server = serve(
        hostname: 'localhost',
        port: 3000,
        reusePort: false,
        fetch: fetch,
      );

      expect(server.options.hostname, 'localhost');
      expect(server.options.port, 3000);
      expect(server.options.reusePort, isFalse);
      expect(server.options.fetch, fetch);
    });
  });

  test('should create server with default', () async {
    fetch(_, __) => throw Error();
    server = serve(fetch: fetch);
    await server.ready();

    expect(server.runtime, isNotNull);
    expect(server.hostname, isNotNull);
    expect(server.port, isNotNull);
    expect(server.url, isNotNull);
  });

  test('should create server with custom options', () async {
    fetch(_, __) => throw Error();
    server = serve(
      hostname: 'localhost',
      port: 3000,
      reusePort: false,
      fetch: fetch,
    );
    await server.ready();

    expect(server.hostname, 'localhost');
    expect(server.port, 3000);
    expect(server.url, 'http://localhost:3000');
  });

  test('fetch should return the result as is', () async {
    final request = Request(
      method: 'GET',
      url: Uri.http('example.com', '/test'),
      runtime: null,
    );
    final response = Response(null, status: 200);
    server = serve(fetch: (req, s) {
      expect(req, request);
      expect(s, server);
      return response;
    });

    expect(await server.fetch(request), response);
  });

  test('ports should be shared', () async {
    fetch(_, __) => throw Error();
    server = serve(fetch: fetch, port: 3000, reusePort: true);
    final server2 = serve(fetch: fetch, port: 3000, reusePort: true);

    await server.ready();
    await server2.ready();

    expect(server.port, server2.port);
    await server2.close(force: true);
  });
}
