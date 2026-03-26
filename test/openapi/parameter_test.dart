import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi parameter', () {
    test('serializes path parameter with schema and forced required', () {
      final parameter = OpenAPIParameter.path(
        'id',
        schema: OpenAPISchema.string(format: 'uuid'),
        description: 'User id',
        style: 'simple',
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(parameter), {
        'name': 'id',
        'in': 'path',
        'required': true,
        'schema': {'type': 'string', 'format': 'uuid'},
        'description': 'User id',
        'style': 'simple',
        'x-source': 'fixture',
      });
    });

    test('serializes query parameter with single-entry content', () {
      final parameter = OpenAPIParameter.query(
        'filter',
        required: true,
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.object({'status': OpenAPISchema.string()}),
          ),
        },
        allowReserved: true,
      );

      expect(decodeJsonValue(parameter), {
        'name': 'filter',
        'in': 'query',
        'required': true,
        'content': {
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'status': {'type': 'string'},
              },
            },
          },
        },
        'allowReserved': true,
      });
    });

    test('rejects missing schema and content', () {
      expect(() => OpenAPIParameter.header('X-Trace'), throwsArgumentError);
    });

    test('rejects schema and content together', () {
      expect(
        () => OpenAPIParameter.query(
          'filter',
          schema: OpenAPISchema.string(),
          content: {
            'application/json': OpenAPIMediaType(
              schema: OpenAPISchema.object({}),
            ),
          },
        ),
        throwsArgumentError,
      );
    });

    test('rejects content with multiple media types', () {
      expect(
        () => OpenAPIParameter.cookie(
          'prefs',
          content: {
            'application/json': OpenAPIMediaType(
              schema: OpenAPISchema.object({}),
            ),
            'text/plain': OpenAPIMediaType(schema: OpenAPISchema.string()),
          },
        ),
        throwsArgumentError,
      );
    });
  });
}
