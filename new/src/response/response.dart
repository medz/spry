import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../http/cookies.dart';
import '../http/headers.dart';
import '../http/http_status.dart';
import '../request/request.dart';
import '../utilities/storage.dart';

abstract interface class Responsible {
  /// Converts self to a [Response] object.
  Future<Response> toResponse(Request request);
}

class Response implements Responsible {
  /// The response storage container.
  ///
  /// **Note:** It is similar to request.storage, but not shared. This is
  /// useful when you need to send specific data to the upper layer middleware
  /// but do not want to share it with the readers of request.storage.
  Storage storage = Storage();

  /// The HTTP response status.
  HTTPStatus status;

  /// The header fields for this HTTP response.
  late final Headers headers;

  /// Get and set `Cookies` for this `Response`.
  final Cookies cookies = Cookies(const [], []);

  @override
  Future<Response> toResponse(Request request) => Future.value(this);

  /// Internal, body stream.
  Stream<Uint8List>? _storage;

  Response({
    this.status = HTTPStatus.ok,
    Object? headers,
    Object? body,
    Encoding encoding = utf8,
  }) {
    this.headers = Headers(headers);
    _storage = switch (body) {
      Uint8List bytes => Stream.value(bytes),
      Stream<Uint8List> stream => stream,
      String string => Stream.value(encoding.encode(string)),
    };
  }
}
