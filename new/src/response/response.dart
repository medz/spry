import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../http/cookies.dart';
import '../http/headers.dart';
import '../json/json_convertible.dart';
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
  int status;

  /// The header fields for this HTTP response.
  final Headers headers;

  /// Get and set `Cookies` for this `Response`.
  final Cookies cookies = Cookies(const [], []);

  @override
  Future<Response> toResponse(Request request) => Future.value(this);

  /// Internal, body stream.
  Stream<Uint8List>? _body;

  /// Returns the body stream.
  Stream<Uint8List> stream() async* {
    if (_body != null) yield* _body!;
  }

  Response({
    this.status = 200,
    Object? headers,
    Object? body,
    Encoding encoding = utf8,
  }) : headers = Headers(headers) {
    _body = switch (body) {
      Uint8List bytes => bytes.asStream,
      Stream<Uint8List> stream => stream,
      Stream<Iterable<int>> stream => stream.asUint8ListStream,
      String string => string.stream(encoding),
      JsonConvertible value => value.stream(encoding),
      Object value => value.jsonEncoded.stream(encoding),
      _ => null,
    };

    // Automatically set the content type header if not set.
    if (this.headers.has('content-type')) return;
    final contentType = switch (body) {
      String _ => 'text/plain; charset=utf-8',
      JsonConvertible _ || Object _ => 'application/json; charset=utf-8',
      _ => 'application/octet-stream',
    };
    this.headers.set('content-type', contentType);
  }
}

extension on JsonConvertible {
  /// Create the JSON stream.
  Stream<Uint8List> stream(Encoding encoding) =>
      toJson().jsonEncoded.stream(encoding);
}

extension on Object? {
  /// Returns the JSON encoded string.
  String get jsonEncoded => json.encode(this);
}

extension on String {
  /// Create the string stream.
  Stream<Uint8List> stream(Encoding encoding) async* {
    yield encoding.encode(this).asUint8List;
  }
}

extension on Stream<Iterable<int>> {
  /// Cast to Uint8List stream
  Stream<Uint8List> get asUint8ListStream async* {
    await for (final element in this) {
      yield Uint8List.fromList(element.toList());
    }
  }
}

extension on Iterable<int> {
  /// Cast to Uint8List
  Uint8List get asUint8List => Uint8List.fromList(toList());
}

extension on Uint8List {
  /// As stream
  Stream<Uint8List> get asStream async* {
    yield this;
  }
}
