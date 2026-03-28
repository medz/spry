import 'package:spry/client.dart' as client;
import 'package:test/test.dart';

final class _TestClient extends client.BaseSpryClient {
  const _TestClient({required super.endpoint, super.headers});
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
}
