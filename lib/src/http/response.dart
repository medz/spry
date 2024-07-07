import 'dart:convert';
import 'dart:typed_data';

import 'headers/headers.dart';
import 'headers/headers+rebuild.dart';
import 'headers/headers_builder+set.dart';
import 'http_message/http_message.dart';
import 'http_status_reason_phrase.dart';

abstract interface class Response implements HttpMessage {
  const factory Response(
    final Stream<Uint8List>? body, {
    final int status,
    final String statusText,
    final Headers headers,
    final Encoding encoding,
  }) = _ResponseImpl;

  factory Response.text(
    final String body, {
    final int status = 200,
    final String? statusText,
    final Headers headers = const Headers(),
    final Encoding encoding = utf8,
  }) {
    return _ResponseImpl(
      Stream.value(Uint8List.fromList(encoding.encode(body))),
      status: status,
      statusText: statusText,
      headers: headers
          .resetOf('content-length', body.length.toString())
          .resetOf('content-type', 'text/plain; charset=${encoding.name}'),
    );
  }

  factory Response.json(
    final body, {
    final int status = 200,
    final String? statusText,
    final Headers headers = const Headers(),
    final Encoding encoding = utf8,
  }) {
    final bytes = Uint8List.fromList(encoding.encode(json.encode(body)));

    return _ResponseImpl(
      Stream.value(bytes),
      status: status,
      statusText: statusText,
      headers: headers
          .resetOf('content-length', bytes.lengthInBytes.toString())
          .resetOf(
              'content-type', 'application/json; charset=${encoding.name}'),
    );
  }

  factory Response.formURLEncoded(
    final Map<String, String> form, {
    final int status = 200,
    final String? statusText,
    final Headers headers = const Headers(),
    final Encoding encoding = utf8,
  }) {
    final text = form.entries.map((e) {
      return '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}';
    }).join('&');
    final bytes = Uint8List.fromList(encoding.encode(text));

    return _ResponseImpl(
      Stream.value(bytes),
      status: status,
      statusText: statusText,
      headers: headers
          .resetOf('content-length', bytes.lengthInBytes.toString())
          .resetOf('content-type',
              'application/x-www-form-urlencoded; charset=${encoding.name}'),
    );
  }

  int get status;
  String get statusText;
}

final class _ResponseImpl implements Response {
  const _ResponseImpl(
    this.body, {
    this.status = 200,
    final String? statusText,
    this.headers = const Headers(),
    final Encoding? encoding,
  })  : statusReasonPhrase = statusText,
        _encoding = encoding;

  final String? statusReasonPhrase;
  final Encoding? _encoding;

  @override
  Encoding get encoding => _encoding ?? utf8;

  @override
  final int status;

  @override
  final Headers headers;

  @override
  final Stream<Uint8List>? body;

  @override
  String get statusText => statusReasonPhrase ?? status.httpStatusReasonPhrase;
}

extension on Headers {
  Headers resetOf(String name, String value) {
    return rebuild((builder) {
      builder.set(name, value);
    });
  }
}
