import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../../../http/headers.dart';
import '../../../http/request.dart';
import '../../server.dart';
import '_utils.dart';

extension type IncomingHttpHeaders._(JSObject _) implements JSObject {
  external String? get host;
}

@JS('Object')
extension type JSObjectStatic._(JSAny _) {
  external static JSArray<JSArray> entries(JSObject _);
}

@JS('Array')
extension type JSArrayStatic._(JSAny _) {
  external static bool isArray(JSAny? _);
}

extension type IncomingMessage._(web.ReadableStream _)
    implements web.ReadableStream {
  external IncomingHttpHeaders get headers;
  external String? url;
  external String? method;

  Request toSpryRequest(String hostname, int port) {
    final host = headers.host ?? '$hostname:$port';
    final spryHeaders = Headers();
    for (final part in JSObjectStatic.entries(headers).toDart) {
      final [name, values] = part.toDart;
      if (JSArrayStatic.isArray(values)) {
        for (final value in (values as JSArray<JSString>).toDart) {
          spryHeaders.add((name as JSString).toDart, value.toDart);
        }
        continue;
      }

      final value = values.dartify();
      if (value is String) {
        spryHeaders.add((name as JSString).toDart, value);
      }
    }

    return Request(
      method: method ?? 'get',
      url: Uri.parse('http://$host/${url ?? ''}'),
      headers: spryHeaders,
      body: toDartStream(),
    );
  }
}

extension type ServerResponse._(web.WritableStream _)
    implements web.WritableStream {
  external void writeHead(int statis, JSArray<JSArray<JSString>> headers);
  external void write(JSAny chunk);
  external void end();
}

extension type ListenOptions._(JSObject _) implements JSObject {
  external factory ListenOptions({
    String? host,
    int? port,
    bool? exclusive,
  });
}

extension type NodeServer._(JSObject _) implements JSObject {
  external NodeServer listen(ListenOptions options, JSFunction fn);
  external void close();
  external void closeAllConnections();
}

extension type NodeHttp._(JSObject _) implements JSObject {
  external NodeServer createServer(JSFunction requestListener);
}

class RuntimeServer extends Server {
  RuntimeServer(super.options) {
    final completer = Completer<void>();
    future = completer.future;
    void ready() => completer.complete();

    final nodeServerOptions = ListenOptions(
      host: options.hostname,
      port: options.port,
      exclusive: switch (options.reusePort) { true => false, _ => true },
    );

    unawaited(Future.microtask(() async {
      final http = (await importModule('node:http'.toJS).toDart) as NodeHttp;
      runtime = http.createServer(listen.toJS);
      runtime.listen(nodeServerOptions, ready.toJS);
    }));
  }

  late final Future<void> future;

  @override
  late final NodeServer runtime;

  @override
  Future<void> close({bool force = false}) async {
    if (force) {
      runtime.closeAllConnections();
    }
    runtime.close();
  }

  @override
  Future<void> ready() => future;

  void listen(IncomingMessage request, ServerResponse response) {
    unawaited(fetch(request.toSpryRequest(options.hostname, options.port)).then(
      (spryResponse) async {
        final headers = <JSArray<JSString>>[];
        for (final (name, value) in spryResponse.headers) {
          headers.add([name.toJS, value.toJS].toJS);
        }
        response.writeHead(spryResponse.status, headers.toJS);
        await for (final chunk in spryResponse) {
          response.write(chunk.toJS);
        }
        response.end();
      },
    ));
  }
}
