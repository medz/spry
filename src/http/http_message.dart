import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '_utils.dart';
import 'headers.dart';

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

  Future<String> readAsString({Encoding? encoding}) async {
    encoding ??= getContentTypeCharset(headers.get('content-type'));
    final result = StringBuffer();
    await for (final chunk in this) {
      result.write(encoding.decode(chunk));
    }

    return result.toString();
  }

  Future<dynamic> readAsJson({Encoding? encoding}) async {
    return jsonDecode(await readAsString(encoding: encoding));
  }
}
