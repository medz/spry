import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../../http/headers.dart';
import '../../../http/request.dart';
import '../../../http/response.dart';

extension type _UnderlyingSource._(JSObject _) implements JSObject {
  /// The type must set to `bytes`
  external factory _UnderlyingSource({
    JSFunction? start,
    JSFunction? cancel,
    String? type,
  });
}

extension ToDartStream on web.ReadableStream {
  Stream<Uint8List> toDartStream() async* {
    final reader = getReader() as web.ReadableStreamDefaultReader;
    while (true) {
      final result = await reader.read().toDart;
      if (result.done) break;
      if (result.value == null) continue;
      yield (result.value as JSUint8Array).toDart;
    }
  }
}

extension ToWebReadableStream on Stream<Uint8List> {
  web.ReadableStream toWebReadableStream() {
    late final StreamSubscription<Uint8List> subscription;

    void start(web.ReadableStreamDefaultController controller) {
      subscription = listen(
        (chunk) {
          controller.enqueue(chunk.toJS);
        },
        onError: (e) => controller.error(e.jsify()),
        onDone: () => controller.close(),
      );
    }

    void cancel() {
      unawaited(subscription.cancel());
    }

    return web.ReadableStream(_UnderlyingSource(
      type: 'bytes',
      start: start.toJS,
      cancel: cancel.toJS,
    ));
  }
}

extension ToWebHeader on Headers {
  web.Headers toWebHeaders() {
    final headers = web.Headers();
    for (final (name, value) in this) {
      headers.append(name, value);
    }
    return headers;
  }
}

extension ToSpryHeaders on web.Headers {
  @JS('forEach')
  external void _forEach(JSFunction fn);

  Headers toSpryHeaders() {
    final headers = Headers();
    void fn(String value, String name) => headers.add(name, value);
    _forEach(fn.toJS);

    return headers;
  }
}

extension ToWebRequest on Request {
  web.Request toWebRequest() {
    return web.Request(
      url.toString().toJS,
      web.RequestInit(
        method: method,
        headers: headers.toWebHeaders(),
        body: toWebReadableStream(),
      ),
    );
  }
}

extension ToSpryRequest on web.Request {
  Request toSpryRequest() {
    return Request(
      method: method,
      url: Uri.parse(url),
      headers: headers.toSpryHeaders(),
      body: body?.toDartStream(),
    );
  }
}

extension ToWebResponse on Response {
  web.Response toWebResponse() {
    return web.Response(
      toWebReadableStream(),
      web.ResponseInit(
        status: status,
        headers: headers.toWebHeaders(),
      ),
    );
  }
}
