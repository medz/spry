import 'package:spry/client.dart' as client;
import 'package:test/test.dart';

final class _TestClient extends client.BaseSpryClient {
  _TestClient({required super.endpoint, super.headers});
}

final class _TestClientWithGlobalHeaders extends client.BaseSpryClient {
  _TestClientWithGlobalHeaders({required super.endpoint});

  @override
  client.Headers get globalHeaders => client.Headers({'x-client': 'test'});
}

void main() {
  test('re-exports client public API', () async {
    final base = _TestClient(
      endpoint: Uri.parse('https://api.example.com'),
      headers: () => client.Headers({'authorization': 'Bearer test'}),
    );
    final routes = client.ClientRoutes(base);

    expect(base.endpoint, Uri.parse('https://api.example.com'));
    expect(base.globalHeaders, isNull);
    expect(await base.headers?.call(), isA<client.Headers>());
    expect(routes.client, same(base));
  });

  test('builds oxy runtime from endpoint and global headers', () {
    final base = _TestClientWithGlobalHeaders(
      endpoint: Uri.parse('https://api.example.com'),
    );

    expect(base.oxy, isA<client.Oxy>());
    expect(base.oxy.config.baseUrl, Uri.parse('https://api.example.com'));
    expect(base.oxy.config.defaultHeaders, isNotNull);
    expect(
      client.Headers(base.oxy.config.defaultHeaders).get('x-client'),
      'test',
    );
    expect(identical(base.oxy, base.oxy), isTrue);
  });
}
