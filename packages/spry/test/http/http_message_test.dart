import 'dart:convert';
import 'dart:typed_data';

import 'package:spry/spry.dart';
import 'package:test/test.dart';

final class TestHttpMessage implements HttpMessage {
  const TestHttpMessage({
    this.headers = const Headers(),
    this.body,
  });

  @override
  final Stream<Uint8List>? body;

  @override
  final Headers headers;

  @override
  Utf8Codec get encoding => utf8;
}

void main() {
  test('.text', () async {
    final value = 'abc123';
    final message = TestHttpMessage(body: Stream.value(utf8.encode(value)));

    expect(await message.text(), equals(value));
  });

  test('.json', () async {
    final value = [1, 'a', 2.3];
    final message =
        TestHttpMessage(body: Stream.value(utf8.encode(json.encode(value))));

    expect(await message.json(), value);
  });
}
