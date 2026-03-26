import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi server', () {
    test('rejects non-String description fields', () {
      expect(
        () => OpenAPIServer.fromJson({
          'url': 'https://api.example.com',
          'description': 42,
        }),
        throwsFormatException,
      );
      expect(
        () => OpenAPIServerVariable.fromJson({
          'default': 'prod',
          'description': false,
        }),
        throwsFormatException,
      );
    });

    test(
      'reports server variable default errors with serverVariable scope',
      () {
        expect(
          () => OpenAPIServerVariable.fromJson({'default': 42}),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('openapi.serverVariable.default'),
            ),
          ),
        );
      },
    );
  });
}
