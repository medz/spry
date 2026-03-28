import 'package:spry/client.dart' as client;
import 'package:test/test.dart';

void main() {
  test('re-exports client public API', () async {
    final base = client.BaseSpryClient(
      endpoint: Uri.parse('https://api.example.com'),
      headers: () => client.Headers({'authorization': 'Bearer test'}),
    );

    expect(base.endpoint, Uri.parse('https://api.example.com'));
    expect(base.globalHeaders, isNull);
    expect(await base.headers?.call(), isA<client.Headers>());
  });
}
