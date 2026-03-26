import 'package:spry/openapi.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('openapi example', () {
    test('serializes inline value example', () {
      final example = OpenAPIExample(
        summary: 'Default',
        description: 'Inline example',
        value: {'id': '42'},
        extensions: {'source': 'fixture'},
      );

      expect(decodeJsonValue(example), {
        'summary': 'Default',
        'description': 'Inline example',
        'value': {'id': '42'},
        'x-source': 'fixture',
      });
    });

    test('serializes external value example', () {
      final example = OpenAPIExample(
        externalValue: 'https://example.com/examples/user.json',
      );

      expect(decodeJsonValue(example), {
        'externalValue': 'https://example.com/examples/user.json',
      });
    });

    test('rejects value and externalValue together', () {
      expect(
        () => OpenAPIExample(
          value: {'id': '42'},
          externalValue: 'https://example.com/examples/user.json',
        ),
        throwsArgumentError,
      );
    });
  });
}
