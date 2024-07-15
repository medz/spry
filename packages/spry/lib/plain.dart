/// This library implements the implementation of Spring plain requests.
library spry.platform.plain;

import 'dart:convert';
import 'dart:typed_data';

import 'spry.dart';

/// Plain Request.
class PlainRequest implements Request {
  PlainRequest({
    required this.method,
    required this.uri,
    Headers? headers,
    this.body,
  }) : headers = headers ?? Headers();

  @override
  Stream<Uint8List>? body;

  @override
  Encoding get encoding => utf8;

  @override
  Headers headers;

  @override
  Uri uri;

  @override
  final String method;
}

/// Plain Platform.
class PlainPlatform implements Platform<PlainRequest, Response> {
  const PlainPlatform();

  @override
  Stream<Uint8List>? getRequestBody(Event event, PlainRequest request) {
    return request.body;
  }

  @override
  Headers getRequestHeaders(Event event, PlainRequest request) {
    return request.headers;
  }

  @override
  Uri getRequestURI(Event event, PlainRequest request) {
    return request.uri;
  }

  @override
  Future<Response> respond(
      Event event, PlainRequest request, Response response) async {
    return response;
  }

  @override
  String getRequestMethod(Event event, PlainRequest request) {
    return request.method;
  }

  @override
  String getClientAddress(Event event, PlainRequest request) {
    return '';
  }
}
