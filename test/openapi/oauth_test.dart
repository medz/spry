import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi oauth', () {
    test('serializes all oauth flow variants', () {
      final flows = OpenAPIOAuthFlows(
        implicit: OpenAPIOAuthFlow.implicit(
          authorizationUrl: 'https://example.com/oauth/authorize',
          refreshUrl: 'https://example.com/oauth/refresh',
          scopes: {'users:read': 'Read users'},
          extensions: {'mode': 'implicit'},
        ),
        password: OpenAPIOAuthFlow.password(
          tokenUrl: 'https://example.com/oauth/token',
          scopes: {'users:write': 'Write users'},
        ),
        clientCredentials: OpenAPIOAuthFlow.clientCredentials(
          tokenUrl: 'https://example.com/oauth/token',
          scopes: {'service:read': 'Read service data'},
        ),
        authorizationCode: OpenAPIOAuthFlow.authorizationCode(
          authorizationUrl: 'https://example.com/oauth/authorize',
          tokenUrl: 'https://example.com/oauth/token',
          refreshUrl: 'https://example.com/oauth/refresh',
          scopes: {'users:read': 'Read users', 'users:write': 'Write users'},
        ),
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(flows), {
        'implicit': {
          'authorizationUrl': 'https://example.com/oauth/authorize',
          'refreshUrl': 'https://example.com/oauth/refresh',
          'scopes': {'users:read': 'Read users'},
          'x-mode': 'implicit',
        },
        'password': {
          'tokenUrl': 'https://example.com/oauth/token',
          'scopes': {'users:write': 'Write users'},
        },
        'clientCredentials': {
          'tokenUrl': 'https://example.com/oauth/token',
          'scopes': {'service:read': 'Read service data'},
        },
        'authorizationCode': {
          'authorizationUrl': 'https://example.com/oauth/authorize',
          'tokenUrl': 'https://example.com/oauth/token',
          'refreshUrl': 'https://example.com/oauth/refresh',
          'scopes': {'users:read': 'Read users', 'users:write': 'Write users'},
        },
        'x-source': 'fixture',
      });
    });

    test('serializes oauth2 security scheme with flows', () {
      final scheme = OpenAPISecurityScheme.oauth2(
        flows: OpenAPIOAuthFlows(
          clientCredentials: OpenAPIOAuthFlow.clientCredentials(
            tokenUrl: 'https://example.com/oauth/token',
            scopes: {'service:read': 'Read service data'},
          ),
        ),
        description: 'OAuth2 auth',
      );

      expect(decodeJsonValue(scheme), {
        'type': 'oauth2',
        'flows': {
          'clientCredentials': {
            'tokenUrl': 'https://example.com/oauth/token',
            'scopes': {'service:read': 'Read service data'},
          },
        },
        'description': 'OAuth2 auth',
      });
    });
  });
}
