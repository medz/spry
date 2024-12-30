import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart' show MediaType;

import '../_utils.dart';
import 'formdata.dart';
import 'headers.dart';
import 'http_message.dart';

/// HTTP Response.
class Response extends HttpMessage {
  /// Creates a new [Response] instance.
  Response(
    Stream<Uint8List>? body, {
    this.status = 200,
    super.headers,
  }) : super(body: body);

  /// Creates a new [Response] from string value.
  factory Response.fromString(
    String body, {
    int status = 200,
    Headers? headers,
  }) {
    final bytes = utf8.encode(body);
    return Response(Stream.value(bytes), status: status, headers: headers)
      ..headers.set('Content-Type', 'text/plain')
      ..headers.set('Content-Length', bytes.lengthInBytes.toString());
  }

  /// Creates a new [Response] from bytes.
  factory Response.fromBytes(
    Uint8List body, {
    int status = 200,
    Headers? headers,
  }) {
    final res = Response(Stream.value(body), status: status, headers: headers);
    if (!res.headers.any((e) => e.$1 == 'content-type')) {
      res.headers.set('content-type', 'application/octet-stream');
    }
    res.headers.set('content-length', body.lengthInBytes.toString());

    return res;
  }

  /// Creates a new [Response] from JSON object.
  factory Response.fromJson(
    Object? body, {
    int status = 200,
    Headers? headers,
  }) {
    final bytes = utf8.encode(json.encode(body));
    return Response(Stream.value(bytes), status: status, headers: headers)
      ..headers.set('content-type', 'application/json')
      ..headers.set('content-length', bytes.lengthInBytes.toString());
  }

  /// Creates a new [Response] from [FromData].
  factory Response.fromFormData(
    FormData body, {
    int status = 200,
    Headers? headers,
  }) {
    final boundary = createUniqueID();
    return Response(body.toStream(boundary), status: status, headers: headers)
      ..headers.set('content-type', 'multipart/form-data; boundary=$boundary');
  }

  /// Returns the [Response] status code.
  final int status;

  @override
  Headers get headers {
    final headers = super.headers;
    if (headers.has('Content-Type')) {
      final contentType = MediaType.parse(headers.get('Content-Type')!);
      if (!contentType.parameters.containsKey('charset')) {
        final newType = contentType.change(
          parameters: {'charset': 'utf-8'},
          clearParameters: false,
        );
        headers.set('Content-Type', newType.toString());
      }
    }

    return headers;
  }
}
