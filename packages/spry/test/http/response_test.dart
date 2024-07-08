import 'dart:convert';
import 'dart:io';

import 'package:spry/spry.dart';
import 'package:test/test.dart';

void main() {
  test('default factory', () async {
    const res = Response(null);

    expect(res, equals(const Response(null)));
    expect(res.body, isNull);
    expect(res.status, equals(200));
    expect(res.statusText, equals('OK'));
    expect(await res.text(), isNull);
  });

  test('text factory', () async {
    final res = Response.text('foo');
    final contentType = ContentType.parse(res.headers.get('content-type')!);

    expect(res.headers.get('content-length'), equals('3'));
    expect(contentType.primaryType, equals('text'));
    expect(contentType.subType, equals('plain'));
    expect(contentType.charset, equals('utf-8'));
    expect(await res.text(), equals('foo'));
  });

  test('json factory', () async {
    final res = Response.json([1, 2]);
    final contentType = ContentType.parse(res.headers.get('content-type')!);

    expect(contentType.primaryType, equals('application'));
    expect(contentType.subType, equals('json'));
    expect(contentType.charset, equals('utf-8'));
    expect(
      res.headers.get('content-length'),
      equals(json.encode([1, 2]).length.toString()),
    );
    expect(await res.json(), [1, 2]);
  });

  test('.status', () {
    const res1 = Response(null, status: 200);
    const res2 = Response(null, status: 999);

    expect(res1.status, equals(200));
    expect(res2.status, equals(999));
  });

  test('.statusText', () {
    const res1 = Response(null, status: 200);
    const res2 = Response(null, status: 999);
    const res3 = Response(null, statusText: 'test');

    expect(res1.statusText, equals('OK'));
    expect(res2.statusText, equals('Unknown'));
    expect(res3.statusText, equals('test'));
  });
}
