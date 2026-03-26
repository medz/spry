import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi media type', () {
    test('serializes schema, example and encoding', () {
      final mediaType = OpenAPIMediaType(
        schema: OpenAPISchema.object({'id': OpenAPISchema.string()}),
        example: {'id': '42'},
        encoding: {
          'avatar': OpenAPIEncoding(
            contentType: 'image/png',
            headers: {
              'X-Mode': OpenAPIRef.inline(
                OpenAPIHeader(
                  schema: OpenAPISchema.string(),
                  description: 'inline',
                ),
              ),
            },
            style: 'form',
            explode: true,
            allowReserved: false,
            extensions: {'variant': 'upload'},
          ),
        },
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(mediaType), {
        'schema': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
          },
        },
        'example': {'id': '42'},
        'encoding': {
          'avatar': {
            'contentType': 'image/png',
            'headers': {
              'X-Mode': {
                'description': 'inline',
                'schema': {'type': 'string'},
              },
            },
            'style': 'form',
            'explode': true,
            'allowReserved': false,
            'x-variant': 'upload',
          },
        },
        'x-source': 'fixture',
      });
    });

    test('serializes examples when example is absent', () {
      final mediaType = OpenAPIMediaType(
        examples: {'ok': OpenAPIRef.inline(OpenAPIExample(summary: 'OK'))},
      );

      expect(decodeJsonValue(mediaType), {
        'examples': {
          'ok': {'summary': 'OK'},
        },
      });
    });

    test('rejects example and examples together', () {
      expect(
        () => OpenAPIMediaType(
          example: 'ok',
          examples: {'ok': OpenAPIRef.inline(OpenAPIExample(summary: 'OK'))},
        ),
        throwsArgumentError,
      );
    });
  });
}
