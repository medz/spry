import 'package:spry/openapi.dart';
import 'package:test/test.dart';

void main() {
  group('openapi path item', () {
    test('rejects non-object parameter entries in fromJson', () {
      expect(
        () => OpenAPIPathItem.fromJson({
          'parameters': ['not-a-map'],
        }),
        throwsFormatException,
      );
    });
  });
}
