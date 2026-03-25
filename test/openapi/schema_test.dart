import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi schema', () {
    test('supports object and boolean schemas', () {
      final anything = OpenAPISchema.anything();
      final nothing = OpenAPISchema.nothing();
      final object = OpenAPISchema.object({
        'id': OpenAPISchema.string(),
        'name': OpenAPISchema.string(description: 'Display name'),
      });

      expect(decodeJsonValue(anything), isTrue);
      expect(decodeJsonValue(nothing), isFalse);
      expect(decodeJsonValue(object), {
        'type': 'object',
        'properties': {
          'id': {'type': 'string'},
          'name': {'type': 'string', 'description': 'Display name'},
        },
      });
    });

    test('nullable adds null to object schema types', () {
      final nullable = OpenAPISchema.nullable(
        OpenAPISchema.string(format: 'uuid'),
      );

      expect(decodeJsonValue(nullable), {
        'type': ['string', 'null'],
        'format': 'uuid',
      });
    });

    test('nullable handles boolean schema special cases', () {
      expect(
        decodeJsonValue(OpenAPISchema.nullable(OpenAPISchema.anything())),
        true,
      );
      expect(
        decodeJsonValue(OpenAPISchema.nullable(OpenAPISchema.nothing())),
        {'type': 'null'},
      );
    });

    test('additional merges extras but explicit fields win', () {
      final schema = OpenAPISchema.object(
        {'id': OpenAPISchema.string()},
        additionalProperties: false,
        additional: {
          'type': 'string',
          'description': 'User object',
          'x-origin': 'fixture',
        },
      );

      expect(decodeJsonValue(schema), {
        'type': 'object',
        'description': 'User object',
        'x-origin': 'fixture',
        'properties': {
          'id': {'type': 'string'},
        },
        'additionalProperties': false,
      });
    });

    test('supports array, ref and composition helpers', () {
      final array = OpenAPISchema.array(
        OpenAPISchema.ref('#/components/schemas/User'),
        minItems: 1,
      );
      final composed = OpenAPISchema.oneOf(
        [OpenAPISchema.string(), OpenAPISchema.integer()],
        additional: {'description': 'String or integer'},
      );

      expect(decodeJsonValue(array), {
        'type': 'array',
        'items': {r'$ref': '#/components/schemas/User'},
        'minItems': 1,
      });
      expect(decodeJsonValue(composed), {
        'oneOf': [
          {'type': 'string'},
          {'type': 'integer'},
        ],
        'description': 'String or integer',
      });
    });
  });
}
