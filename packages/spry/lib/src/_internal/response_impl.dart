import 'dart:convert';
import 'dart:io';

import 'package:spry/src/context.dart';

import '../spry_exception.dart';
import '../response.dart';

class ResponseImpl extends Response {
  /// Creates a new [ResponseImpl] instance.
  ResponseImpl(this.response);

  @override
  late final Context context;

  /// [HttpResponse] instance.
  final HttpResponse response;

  @override
  final List<Cookie> cookies = [];

  Stream<List<int>>? _bodyStream;

  @override
  HttpHeaders get headers => response.headers;

  @override
  Stream<List<int>> read() {
    if (!isBodyReady) {
      throw SpryException.fromMessage('Response body is not ready.');
    }

    final Stream<List<int>> bodyStream = _bodyStream!;
    _bodyStream = null;

    return bodyStream;
  }

  @override
  void send([Object? object]) {
    if (object == null) {
      _bodyStream = Stream.empty();
    } else if (object is String) {
      final Encoding encoding = this.encoding ?? utf8;

      _bodyStream = Stream.value(encoding.encode(object));
    } else if (object is List) {
      _bodyStream = Stream.value(object.cast());
    } else if (object is Stream) {
      _bodyStream = object.cast();
    } else {
      throw SpryException.fromMessage(
          'Response body must be a String, List or Stream.');
    }
  }

  @override
  bool get isBodyReady => _bodyStream != null;

  @override
  Future<void> close() async {
    await response.close();
  }

  @override
  Future<void> redirect(Uri location,
      {int status = HttpStatus.movedTemporarily}) async {
    await response.redirect(location, status: status);
  }
}
