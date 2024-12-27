import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '_utils.dart';
import 'formdata.dart';
import 'headers.dart';
import 'url_search_params.dart';

abstract class HttpMessage extends Stream<Uint8List> {
  HttpMessage({Headers? headers, Stream<Uint8List>? body})
      : headers = headers ?? Headers(),
        body = body ?? const Stream.empty();

  final Headers headers;
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

  Future<Uint8List> readAsBytes() async {
    final length = int.parse(headers.get('content-length') ?? '0');
    final result = Uint8List(length);
    await for (final chunk in this) {
      result.addAll(chunk);
    }

    return result;
  }

  Future<String> readAsString() async {
    final result = StringBuffer();
    await for (final chunk in this) {
      result.write(utf8.decode(chunk));
    }

    return result.toString();
  }

  Future<dynamic> readAsJson() async {
    return jsonDecode(await readAsString());
  }

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

  Future<URLSearchParams> readAsUrlencoded() async {
    return URLSearchParams.parse(await readAsString());
  }
}
