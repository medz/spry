import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi response', () {
    test('serializes response with headers, content and links', () {
      final response = OpenAPIResponse(
        description: 'User response',
        headers: {
          'X-Trace': OpenAPIRef.inline(
            OpenAPIHeader(
              schema: OpenAPISchema.string(),
              description: 'Trace id',
            ),
          ),
        },
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.object({'id': OpenAPISchema.string()}),
          ),
        },
        links: {
          'self': OpenAPIRef.inline(
            OpenAPILink(
              operationId: 'getUser',
              parameters: {'id': r'$response.body#/id'},
            ),
          ),
          'docs': OpenAPIRef.ref(
            '#/components/links/UserDocs',
            description: 'Shared docs link',
          ),
        },
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(response), {
        'description': 'User response',
        'headers': {
          'X-Trace': {
            'description': 'Trace id',
            'schema': {'type': 'string'},
          },
        },
        'content': {
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'id': {'type': 'string'},
              },
            },
          },
        },
        'links': {
          'self': {
            'operationId': 'getUser',
            'parameters': {'id': r'$response.body#/id'},
          },
          'docs': {
            r'$ref': '#/components/links/UserDocs',
            'description': 'Shared docs link',
          },
        },
        'x-source': 'fixture',
      });
    });
  });
}
