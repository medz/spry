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

  factory Response.fromString({
    int status = 200,
    Headers? headers,
    required String body,
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

  factory Response.fromBytes({
    int status = 200,
    Headers? headers,
    required Uint8List body,
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

  factory Response.fromJson({
    int status = 200,
    Headers? headers,
    Object? body,
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

  factory Response.fromFormData({
    int status = 200,
    Headers? headers,
    required FormData body,
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
