import 'dart:convert';

import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi security', () {
    test('serializes security requirements and apiKey schemes', () {
      final requirement = OpenAPISecurityRequirement({
        'bearerAuth': [],
        'oauth': ['users:read'],
      });
      final scheme = OpenAPISecurityScheme.apiKey(
        name: 'X-API-Key',
        location: OpenAPIApiKeyLocation.header,
        description: 'API key auth',
        extensions: {'source': 'fixture'},
      );

      expect(_decodeJsonValue(requirement), {
        'bearerAuth': [],
        'oauth': ['users:read'],
      });
      expect(_decodeJsonValue(scheme), {
        'type': 'apiKey',
        'name': 'X-API-Key',
        'in': 'header',
        'description': 'API key auth',
        'x-source': 'fixture',
      });
    });

    test('serializes http bearer scheme', () {
      final scheme = OpenAPISecurityScheme.http(
        scheme: 'bearer',
        bearerFormat: 'JWT',
      );

      expect(_decodeJsonValue(scheme), {
        'type': 'http',
        'scheme': 'bearer',
        'bearerFormat': 'JWT',
      });
    });

    test('rejects bearerFormat for non-bearer http schemes', () {
      expect(
        () => OpenAPISecurityScheme.http(scheme: 'basic', bearerFormat: 'JWT'),
        throwsArgumentError,
      );
    });
  });
}

dynamic _decodeJsonValue(dynamic value) => jsonDecode(jsonEncode(value));
