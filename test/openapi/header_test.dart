import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi header', () {
    test('serializes schema-based header', () {
      final header = OpenAPIHeader(
        description: 'Trace id',
        required: true,
        deprecated: false,
        schema: OpenAPISchema.string(format: 'uuid'),
        style: 'simple',
        explode: false,
        example: 'trace-1',
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(header), {
        'description': 'Trace id',
        'required': true,
        'deprecated': false,
        'schema': {'type': 'string', 'format': 'uuid'},
        'style': 'simple',
        'explode': false,
        'example': 'trace-1',
        'x-source': 'fixture',
      });
    });

    test('serializes content-based header with examples', () {
      final header = OpenAPIHeader(
        content: {
          'application/json': OpenAPIMediaType(
            schema: OpenAPISchema.object({'mode': OpenAPISchema.string()}),
          ),
        },
        examples: {
          'default': OpenAPIRef.inline(OpenAPIExample(summary: 'Default')),
        },
      );

      expect(decodeJsonValue(header), {
        'content': {
          'application/json': {
            'schema': {
              'type': 'object',
              'properties': {
                'mode': {'type': 'string'},
              },
            },
          },
        },
        'examples': {
          'default': {'summary': 'Default'},
        },
      });
    });

    test('rejects missing schema and content', () {
      expect(() => OpenAPIHeader(), throwsArgumentError);
    });

    test('rejects schema and content together', () {
      expect(
        () => OpenAPIHeader(
          schema: OpenAPISchema.string(),
          content: {
            'text/plain': OpenAPIMediaType(schema: OpenAPISchema.string()),
          },
        ),
        throwsArgumentError,
      );
    });

    test('rejects multi-entry content', () {
      expect(
        () => OpenAPIHeader(
          content: {
            'text/plain': OpenAPIMediaType(schema: OpenAPISchema.string()),
            'application/json': OpenAPIMediaType(
              schema: OpenAPISchema.object({}),
            ),
          },
        ),
        throwsArgumentError,
      );
    });

    test('rejects example and examples together', () {
      expect(
        () => OpenAPIHeader(
          schema: OpenAPISchema.string(),
          example: 'trace-1',
          examples: {
            'default': OpenAPIRef.inline(OpenAPIExample(summary: 'Default')),
          },
        ),
        throwsArgumentError,
      );
    });
  });
}
