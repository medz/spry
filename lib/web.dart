import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'spry.dart';

/// Create a new [Event] for web.
Event createWebEvent(Spry app, web.Request request) {
  final spryRequest = Request(
    method: request.method,
    uri: Uri.parse(request.url),
    headers: request.headers.toSpryHeaders(),
    body: _getWebRequestBody(request),
  );

  return createEvent(app, spryRequest);
}

/// Sprt response to web response object.
web.Response toWebResponse(Response response) {
  final init = web.ResponseInit(
    status: response.status,
    statusText: response.statusText,
    headers: toWebHeaders(response.headers),
  );

  if (response.body == null) {
    return web.Response(null, init);
  }

  return web.Response(_toWebReadableStream(response.body!), init);
}

/// Spry headers to web headers object.
web.Headers toWebHeaders(Headers headers) {
  final webHeaders = web.Headers();

  for (final (name, value) in headers) {
    webHeaders.append(name, value);
  }

  return webHeaders;
}

/// Creates a new web handler for the Spry application.
Future<web.Response> Function(web.Request) toWebHandler(Spry app) {
  final handler = toHandler(app);

  return (webRequest) async {
    final event = createWebEvent(app, webRequest);
    final response = await handler(event);

    return toWebResponse(response);
  };
}

extension on web.Headers {
  @JS('forEach')
  external void _forEach(JSFunction fn);

  void forEach(
    void Function(String value, String name, web.Headers headers) fn,
  ) {
    _forEach(fn.toJS);
  }

  Headers toSpryHeaders() {
    final headers = Headers();
    forEach((value, key, _) {
      headers.add(key, value);
    });

    for (final value in getSetCookie().toDart) {
      headers.add('set-cookie', value.toDart);
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

Stream<Uint8List>? _getWebRequestBody(web.Request request) {
  if (request.body == null) return null;

  return Stream<Uint8List>.fromFuture(
    request.arrayBuffer().toDart.then((value) => value.toDart.asUint8List()),
  );
}

web.ReadableStream _toWebReadableStream(Stream<Uint8List> stream) {
  late final StreamSubscription<Uint8List> subscription;
  void start(_ReadableByteStreamController controller) {
    subscription = stream.listen((event) {
      controller.enqueue(event.toJS);

      if (controller.desiredSize == null ||
          controller.desiredSize == -1 ||
          controller.desiredSize == 0) {
        subscription.pause();
      }
    });
    subscription.onDone(() => controller.close());
    subscription.onError((error) {
      final e = switch (error) {
        String(toJS: final toJS) => toJS,
        Exception exception => Error.safeToString(exception).toJS,
        Error error => Error.safeToString(error).toJS,
        JSAny any => any,
        _ => error.jsify(),
      };

      controller.error(e);
    });
  }

  final underlyingSource = JSObject()
    ..['type'] = 'bytes'.toJS
    ..['start'] = start.toJS
    ..['pull'] = ((JSAny _) => subscription.resume()).toJS
    ..['cancel'] = (() {
      unawaited(subscription.cancel());
    }).toJS;

  return web.ReadableStream(underlyingSource);
}
