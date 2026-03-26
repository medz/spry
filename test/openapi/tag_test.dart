import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi tag', () {
    test('reports external docs validation with external docs scope', () {
      expect(
        () => OpenAPIExternalDocs.fromJson({'url': 42}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('openapi external docs.url'),
          ),
        ),
      );
      expect(
        () => OpenAPIExternalDocs.fromJson({
          'url': 'https://example.com',
          'description': false,
        }),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('openapi external docs.description'),
          ),
        ),
      );
    });
  });
}
