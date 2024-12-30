import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '_utils.dart';
import 'formdata.dart';
import 'headers.dart';
import 'url_search_params.dart';

/// Abstract http message class.
abstract class HttpMessage extends Stream<Uint8List> {
  /// Creates a new [Request]/[Response].
  ///
  /// See:
  /// - [Request]
  /// - [Response]
  HttpMessage({Headers? headers, Stream<Uint8List>? body})
      : headers = headers ?? Headers(),
        body = body ?? const Stream.empty();

  /// Returns the [Request]/[Response] headers.
  final Headers headers;

  /// Returns the [Request]/[Response] body stream.
  final Stream<Uint8List> body;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return body.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Read the body as bytes.
  Future<Uint8List> readAsBytes() async {
    final length = int.parse(headers.get('content-length') ?? '0');
    final result = Uint8List(length);
    await for (final chunk in this) {
      result.addAll(chunk);
    }

    return result;
  }

  /// Read the body as string.
  Future<String> readAsString() async {
    final result = StringBuffer();
    await for (final chunk in this) {
      result.write(utf8.decode(chunk));
    }

    return result.toString();
  }

  /// Read the body as dynamic value with JSON decode.
  Future<dynamic> readAsJson() async {
    return jsonDecode(await readAsString());
  }

  /// Read the body as to [FormData].
  Future<FormData> readAsFormData({
    String? boundary,
  }) {
    final contentType = headers.get('content-type');
    boundary ??= getHeaderSubParam(contentType, 'boundary');
    if (boundary == null || boundary.isEmpty) {
      throw StateError('invalid boundary');
    }

    return FormData.parse(boundary: boundary, stream: body);
  }

  /// Read the body as to [URLSearchParams].
  Future<URLSearchParams> readAsUrlencoded() async {
    return URLSearchParams.parse(await readAsString());
  }
}
