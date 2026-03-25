import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi request body', () {
    test('serializes request body content', () {
      final requestBody = OpenAPIRequestBody(
        description: 'Create user payload',
        required: true,
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.object({'name': OpenAPISchema.string()}),
          ),
        },
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(requestBody), {
        'content': {
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'name': {'type': 'string'},
              },
            },
          },
        },
        'description': 'Create user payload',
        'required': true,
        'x-source': 'fixture',
      });
    });
  });
}
