import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../_utils.dart';
import 'formdata.dart';
import 'headers.dart';
import 'http_message.dart';

class Response extends HttpMessage {
  Response({
    this.status = 200,
    super.headers,
    super.body,
  });

  factory Response.fromString(
    String body, {
    int status = 200,
    Headers? headers,
  }) {
    final bytes = utf8.encode(body);
    return Response(
      status: status,
      headers: headers,
      body: Stream.value(bytes),
    )
      ..headers.set('Content-Type', 'text/plain')
      ..headers.set('Content-Length', bytes.lengthInBytes.toString());
  }

  factory Response.fromBytes(
    Uint8List body, {
    int status = 200,
    Headers? headers,
  }) {
    final res = Response(
      status: status,
      headers: headers,
      body: Stream.value(body),
    );
    if (!res.headers.any((e) => e.$1 == 'content-type')) {
      res.headers.set('content-type', 'application/octet-stream');
    }
    res.headers.set('content-length', body.lengthInBytes.toString());

    return res;
  }

  factory Response.fromJson(
    Object? body, {
    int status = 200,
    Headers? headers,
  }) {
    final bytes = utf8.encode(json.encode(body));
    return Response(
      status: status,
      headers: headers,
      body: Stream.value(bytes),
    )
      ..headers.set('content-type', 'application/json')
      ..headers.set('content-length', bytes.lengthInBytes.toString());
  }

  factory Response.fromFormData(
    FormData body, {
    int status = 200,
    Headers? headers,
  }) {
    final boundary = createUniqueID();
    return Response(
      status: status,
      headers: headers,
      body: body.toStream(boundary),
    )..headers.set('content-type', 'multipart/form-data; boundary=$boundary');
  }

  final int status;
}
