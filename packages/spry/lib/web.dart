@JS()
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:web/web.dart' as web;

import 'spry.dart';

class WebPlatform extends Platform<web.Request, web.Response> {
  const WebPlatform();

  @override
  String getClientAddress(Event event, web.Request request) {
    return '';
  }

  @override
  Stream<Uint8List>? getRequestBody(Event event, web.Request request) {
    if (request.body == null) return null;

    return Stream.fromFuture(() async {
      final bytes = await request.arrayBuffer().toDart;

      return bytes.toDart.asUint8List();
    }());
  }

  @override
  Headers getRequestHeaders(Event event, web.Request request) {
    return request.headers.toSpryHeaders();
  }

  @override
  String getRequestMethod(Event event, web.Request request) {
    return request.method;
  }

  @override
  Uri getRequestURI(Event event, web.Request request) {
    return Uri.parse(request.url);
  }

  @override
  Future<web.Response> respond(
      Event event, web.Request request, Response response) async {
    final init = web.ResponseInit(
      status: response.status,
      statusText: response.statusText,
      headers: response.headers.toWebHeaders(),
    );

    if (response.body == null) {
      return web.Response(null, init);
    }

    late final StreamSubscription<Uint8List> subscription;
    final underlyingSource = web.UnderlyingSource(
      type: "bytes",
      start: (_ReadableByteStreamController controller) {
        subscription = response.body!.listen(
          (event) {
            controller.enqueue(event.toJS);

            if (controller.desiredSize == null ||
                controller.desiredSize == -1 ||
                controller.desiredSize == 0) {
              subscription.pause();
            }
          },
          onError: (error) {
            final e = switch (error) {
              String(toJS: final toJS) => toJS,
              Exception exception => Error.safeToString(exception).toJS,
              Error error => Error.safeToString(error).toJS,
              JSAny any => any,
              _ => error.jsify(),
            };

            controller.error(e);
          },
          onDone: () => controller.close(),
        );
      }.toJS,
      pull: ((JSAny _) {
        subscription.resume();
      }).toJS,
      cancel: (JSAny reason) {
        subscription.cancel();
      }.toJS,
    );
    final readableStream = web.ReadableStream(underlyingSource);

    return web.Response(readableStream, init);
  }
}

extension on web.Headers {
  @JS('forEach')
  external void _forEach(JSFunction fn);

  void forEach(
    void Function(String value, String name, web.Headers headers) fn,
  ) {
    _forEach(fn.toJS);
  }

  external JSArray<JSString> getSetCookie();

  Headers toSpryHeaders() {
    final builder = HeadersBuilder();

    forEach((value, key, _) {
      builder.add(key, value);
    });

    for (final value in getSetCookie().toDart) {
      builder.add('set-cookie', value.toDart);
    }

    return builder.toHeaders();
  }
}

extension on Headers {
  web.Headers toWebHeaders() {
    final headers = web.Headers();

    for (final (name, value) in this) {
      headers.append(name, value);
    }

    return headers;
  }
}

@JS('ReadableByteStreamController')
extension type _ReadableByteStreamController._(JSObject _) implements JSObject {
  external int? get desiredSize;
  external void enqueue(JSUint8Array chunk);
  external void error([JSAny e]);
  external void close();
}
