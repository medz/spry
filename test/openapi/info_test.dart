import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi info', () {
    test('exposes typed contact and license getters', () {
      final contact = OpenAPIContact.fromJson({
        'name': 'Team Spry',
        'url': 'https://example.com',
        'email': 'team@example.com',
      });
      final license = OpenAPILicense.fromJson({
        'name': 'MIT',
        'identifier': 'MIT',
      });

      expect(contact.name, 'Team Spry');
      expect(contact.url, 'https://example.com');
      expect(contact.email, 'team@example.com');
      expect(license.name, 'MIT');
      expect(license.identifier, 'MIT');
      expect(license.url, isNull);
    });

    test(
      'OpenAPILicense.fromJson reports mutually exclusive fields as FormatException',
      () {
        expect(
          () => OpenAPILicense.fromJson({
            'name': 'MIT',
            'identifier': 'MIT',
            'url': 'https://example.com/license',
          }),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('mutually exclusive'),
            ),
          ),
        );
      },
    );

    test('validates required fields and types during parsing', () {
      expect(() => OpenAPILicense.fromJson({}), throwsFormatException);
      expect(
        () => OpenAPIInfo.fromJson({'title': 42, 'version': '1.0.0'}),
        throwsFormatException,
      );
    });
  });
}
