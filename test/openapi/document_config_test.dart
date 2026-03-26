import 'package:spry/openapi.dart';
import 'package:spry/src/openapi/config.dart';
import 'package:test/test.dart';

void main() {
  group('openapi document config', () {
    test('parses security requirements from JSON', () {
      final config = OpenAPIDocumentConfig.fromJson({
        'info': {'title': 'Spry API', 'version': '1.0.0'},
        'security': [
          {
            'bearerAuth': ['read:users'],
          },
        ],
      });

      expect(config.security, [isA<OpenAPISecurityRequirement>()]);
    });

    test('rejects explicit null optional fields consistently', () {
      final baseInfo = {'title': 'Test', 'version': '1.0'};
      for (final key in [
        'components',
        'servers',
        'webhooks',
        'tags',
        'security',
        'externalDocs',
      ]) {
        expect(
          () => OpenAPIDocumentConfig.fromJson({'info': baseInfo, key: null}),
          throwsFormatException,
          reason: 'expected explicit null for $key to fail validation',
        );
      }
    });
  });
}
