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

extension type Socket._(JSObject _) implements JSObject {
  external String? get remoteAddress;
  external String? get remoteFamily;
  external int? get remotePort;
  external String? get localAddress;
  external int? get localPort;
  external String? get localFamily;
}

extension type IncomingMessage._(web.ReadableStream _)
    implements web.ReadableStream {
  external IncomingHttpHeaders get headers;
  external String? url;
  external String? method;
  external Socket get socket;

  Request toSpryRequest() {
    final hostname = headers.host ?? socket.localAddress ?? '';

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
      url: Uri.parse('http://$hostname${url ?? '/'}'),
      headers: spryHeaders,
      body: toDartStream(),
      runtime: this,
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
  external JSAny? address();
}

extension type NodeHttp._(JSObject _) implements JSObject {
  external NodeServer createServer(JSFunction requestListener);
}

extension type AddressInfo._(JSObject _) implements JSObject {
  external String address;
  external int port;
}

class RuntimeServer extends Server<NodeServer, IncomingMessage> {
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
    unawaited(fetch(request.toSpryRequest()).then(
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

  @override
  String? get hostname {
    final addr = runtime.address();
    if (addr.typeofEquals('string')) {
      return (addr as JSString).toDart;
    } else if (addr.typeofEquals('object')) {
      return (addr as AddressInfo).address;
    }

    return null;
  }

  @override
  int? get port {
    final addr = runtime.address();
    if (addr.typeofEquals('object')) {
      return (addr as AddressInfo).port;
    }

    return null;
  }

  @override
  String? remoteAddress(IncomingMessage request) {
    final addr = request.socket.remoteAddress;
    final port = request.socket.remotePort;
    if (addr != null && port != null) {
      final hostname = request.socket.remoteFamily == 'IPv6' ? '[$addr]' : addr;
      return '$hostname:$port';
    }

    return null;
  }
}
