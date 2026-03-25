import 'dart:convert';

import 'package:spry/openapi.dart';
import 'package:spry/src/openapi/config.dart';
import 'package:test/test.dart';

void main() {
  group('openapi webhooks', () {
    test('serializes document webhooks as path items', () {
      final document = OpenAPIDocument(
        info: OpenAPIInfo(title: 'Spry API', version: '1.0.0'),
        paths: {
          '/users/{id}': OpenAPIPathItem(
            get: OpenAPIOperation(
              responses: {
                '200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK')),
              },
            ),
          ),
        },
        webhooks: {
          'userCreated': OpenAPIPathItem(
            $ref: '#/components/pathItems/UserCreated',
          ),
          'userDeleted': OpenAPIPathItem(
            post: OpenAPIOperation(
              responses: {
                '202': OpenAPIRef.inline(
                  OpenAPIResponse(description: 'Accepted'),
                ),
              },
            ),
          ),
        },
      );

      expect(_decodeJsonValue(document)['webhooks'], {
        'userCreated': {r'$ref': '#/components/pathItems/UserCreated'},
        'userDeleted': {
          'post': {
            'responses': {
              '202': {'description': 'Accepted'},
            },
          },
        },
      });
    });

    test('parses webhooks from document config json', () {
      final config = OpenAPIDocumentConfig.fromJson({
        'info': {'title': 'Spry API', 'version': '1.0.0'},
        'webhooks': {
          'userCreated': {r'$ref': '#/components/pathItems/UserCreated'},
        },
      });

      expect(_decodeJsonValue(config)['webhooks'], {
        'userCreated': {r'$ref': '#/components/pathItems/UserCreated'},
      });
      expect(config.webhooks, {'userCreated': isA<OpenAPIPathItem>()});
    });
  });
}

dynamic _decodeJsonValue(dynamic value) => jsonDecode(jsonEncode(value));
