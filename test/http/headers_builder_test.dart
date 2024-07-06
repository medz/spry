import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  test('init values', () {
    expect(HeadersBuilder().toHeaders(), isEmpty);
    expect(HeadersBuilder([('a', '1')]).toHeaders(), [('a', '1')]);
  });

  test('.add', () {
    final builder = HeadersBuilder();

    builder.add('a', '1');
    builder.add('a', '1');
    builder.add('b', '1');

    final headers = builder.toHeaders();
    expect(headers.length, equals(3));
    expect(headers.get('a'), equals('1, 1'));
    expect(headers.get('b'), equals('1'));
    expect(headers.get('c'), isNull);
  });

  test('.remove', () {
    final builder = HeadersBuilder([
      ('a', '1'),
      ('a', '1'),
      ('b', '1'),
    ]);

    builder.remove('a');

    expect(builder.toHeaders(), [('b', '1')]);
  });

  test('.toHeaders', () {
    expect(HeadersBuilder().toHeaders(), isA<Headers>());
  });

  test('.set', () {
    final builder = HeadersBuilder([
      ('a', '1'),
      ('a', '1'),
    ]);

    builder.set('a', '2');
    expect(builder.toHeaders(), [('a', '2')]);
  });
}
