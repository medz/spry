import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  test('impl Iterable<(String, String)>', () {
    expect(Headers(), isA<Iterable<(String, String)>>());
  });

  test('init values', () {
    expect(Headers(), isEmpty);

    final headers = Headers([
      ('a', '1'),
      ('a', '2'),
      ('b', '1'),
    ]);
    expect(headers.length, equals(3));
  });

  test('name ignore case', () {
    final headers = Headers([('BaR', 'foo')]);

    expect(headers.getAll('bAr'), ['foo']);
    expect(headers.get('bar'), 'foo');
  });

  test('.getAll', () {
    final headers = Headers([
      ('a', '1'),
      ('a', '2'),
      ('b', '1'),
    ]);

    expect(headers.getAll('a'), ['1', '2']);
    expect(headers.getAll('b'), ['1']);
    expect(headers.getAll('c'), isEmpty);
  });

  test('.get', () {
    final headers = Headers([
      ('a', '1'),
      ('a', '2'),
      ('b', '1'),
    ]);

    expect(headers.get('a'), equals('1, 2'));
    expect(headers.get('b'), equals('1'));
    expect(headers.get('c'), isNull);
  });

  test('.has', () {
    final headers = Headers([
      ('a', '1'),
      ('a', '2'),
      ('b', '1'),
    ]);

    expect(headers.has('a'), equals(true));
    expect(headers.has('b'), equals(true));
    expect(headers.has('c'), equals(false));
  });

  test('.keys', () {
    final headers = Headers([
      ('a', '1'),
      ('a', '2'),
      ('b', '1'),
    ]);

    expect(headers.keys, ['a', 'b']);
  });

  test('.rebuild', () {
    bool rebuildEffect = false;
    final headers = Headers([('a', '1')]);
    final rebuilt = headers.rebuild((builder) {
      builder.add('b', '1');
      builder.remove('a');
      rebuildEffect = true;
    });

    expect(headers.length, equals(1));
    expect(headers.get('a'), equals('1'));
    expect(rebuilt.get('a'), isNull);
    expect(rebuilt.get('b'), equals('1'));
    expect(rebuildEffect, equals(true));
  });

  test('.toBuilder', () {
    final headers = Headers();

    expect(headers.toBuilder(), isA<HeadersBuilder>());
  });
}
