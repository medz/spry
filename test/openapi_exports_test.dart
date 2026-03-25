import 'package:spry/openapi.dart' as openapi;
import 'package:test/test.dart';

void main() {
  test('re-exports openapi public API', () {
    final info = openapi.OpenAPIInfo(title: 'Fixture API', version: '1.0.0');

    expect(info.title, 'Fixture API');
    expect(info.version, '1.0.0');
  });
}
