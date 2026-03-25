import 'dart:convert';

import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi callback', () {
    test('serializes callback path items', () {
      final OpenAPICallback callback = <String, OpenAPIPathItem>{
        r'{$request.body#/callbackUrl}': OpenAPIPathItem(
          post: OpenAPIOperation(
            responses: {
              '200': OpenAPIRef.inline(OpenAPIResponse(description: 'OK')),
            },
          ),
        ),
        'https://example.com/fallback': OpenAPIPathItem(
          $ref: '#/components/pathItems/UserCreated',
        ),
      };

      expect(_decodeJsonValue(callback), {
        r'{$request.body#/callbackUrl}': {
          'post': {
            'responses': {
              '200': {'description': 'OK'},
            },
          },
        },
        'https://example.com/fallback': {
          r'$ref': '#/components/pathItems/UserCreated',
        },
      });
    });

    test('serializes callbacks through operation and components', () {
      final OpenAPICallback callback = <String, OpenAPIPathItem>{
        r'{$request.body#/callbackUrl}': OpenAPIPathItem(
          $ref: '#/components/pathItems/UserCreated',
        ),
      };

      final operation = OpenAPIOperation(
        callbacks: {'userCreated': OpenAPIRef.inline(callback)},
      );
      final components = OpenAPIComponents(
        callbacks: {'UserCreated': OpenAPIRef.inline(callback)},
      );

      expect(_decodeJsonValue(operation), {
        'callbacks': {
          'userCreated': {
            r'{$request.body#/callbackUrl}': {
              r'$ref': '#/components/pathItems/UserCreated',
            },
          },
        },
      });
      expect(_decodeJsonValue(components), {
        'callbacks': {
          'UserCreated': {
            r'{$request.body#/callbackUrl}': {
              r'$ref': '#/components/pathItems/UserCreated',
            },
          },
        },
      });
    });
  });
}

dynamic _decodeJsonValue(dynamic value) => jsonDecode(jsonEncode(value));
