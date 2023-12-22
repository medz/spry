import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';
import '../responder/responders.dart';
import 'bind_address.dart';
import 'server.dart';
import 'servers.dart';

class DefaultServer extends Server {
  DefaultServer(super.application);

  Completer<void>? _completer;
  StreamSubscription<HttpRequest>? _subscription;
  HttpServer? _server;

  @override
  Future<void> get onShutdown async {
    await _completer?.future;
  }

  @override
  Future<void> shutdown() async {
    await _subscription?.cancel();
    await _server?.close(force: true);

    _completer?.complete();
  }

  InternetAddress get address {
    return switch (application.servers.address) {
      HostAddress(hostname: final hostname) when hostname != null =>
        InternetAddress.tryParse(hostname) ?? InternetAddress.loopbackIPv4,
      _ => InternetAddress.anyIPv4,
    };
  }

  int get port {
    return switch (application.servers.address) {
      HostAddress(port: final port) when port != null => port,
      _ => Servers.defaultPort,
    };
  }

  @override
  Future<void> start() async {
    final server = await HttpServer.bind(
      address,
      port,
      backlog: application.servers.backlog,
      shared: application.servers.shared,
      v6Only: application.servers.onlyIPv6,
    );

    server.autoCompress = application.servers.autoCompress;
    server.idleTimeout = application.servers.idleTimeout;

    if (!application.servers.headers.has('server')) {
      server.defaultResponseHeaders.add(
          'Server', 'Spry default server; dart:io; dart: ${Platform.version}');
    }

    // Set default response headers.
    for (final (name, value) in application.servers.headers.entries()) {
      server.defaultResponseHeaders.add(name, value);
    }

    // Set set-cookie response headers.
    for (final cookie in application.servers.headers.getSetCookie()) {
      server.defaultResponseHeaders.add('Set-Cookie', cookie);
    }

    // Change the hostname and port to the actual values used.
    application.servers.hostname = server.address.host;
    application.servers.port = server.port;

    final subscription = server.listen(respond);

    _server = server;
    _subscription = subscription;
    _completer = Completer<void>();
  }

  Future<void> respond(HttpRequest httpRequest) async {
    final HttpResponse httpResponse = httpRequest.response;
    final request = _RequestImpl(httpRequest);
    final event = RequestEvent(application: application, request: request);
    final response = await application.respond(event);

    for (final (name, value) in response.headers.entries()) {
      httpResponse.headers.add(name, value);
    }
    for (final cookie in response.headers.getSetCookie()) {
      httpResponse.headers.add('Set-Cookie', cookie);
    }

    httpResponse.statusCode = response.status;
    httpResponse.reasonPhrase = response.statusText;

    await for (final chunk in response.body) {
      httpResponse.add(chunk);
    }

    await httpResponse.close();
  }
}

class _RequestImpl implements Request {
  _RequestImpl._(this.request);

  factory _RequestImpl(HttpRequest httpRequest) {
    final headers = Headers();
    httpRequest.headers.forEach((name, values) {
      for (final value in values) {
        headers.append(name, value);
      }
    });
    headers.set('content-length', httpRequest.contentLength.toString());

    final request = Request(
      httpRequest.requestedUri.toString(),
      body: httpRequest,
      cache: headers.get('cache-control')?.contains('no-cache') ?? false
          ? RequestCache.noStore
          : RequestCache.default_,
      method: httpRequest.method,
      headers: headers,
    );

    return _RequestImpl._(request);
  }

  final Request request;

  @override
  final Headers headers = Headers();

  @override
  Future<ArrayBuffer> arrayBuffer() => request.arrayBuffer();

  @override
  Future<Blob> blob() => request.blob();

  @override
  Stream<Uint8List> get body => request.body;

  @override
  bool get bodyUsed => request.bodyUsed;

  @override
  RequestCache get cache => request.cache;

  @override
  Request clone() {
    return _RequestImpl._(request.clone());
  }

  @override
  RequestCredentials get credentials => request.credentials;

  @override
  RequestDestination get destination {
    final dest = headers.get('sec-fetch-dest')?.toLowerCase();
    if (dest == null) return RequestDestination.document;

    return RequestDestination.values.firstWhere(
      (e) => e.value.toLowerCase() == dest,
      orElse: () => RequestDestination.document,
    );
  }

  @override
  Future<FormData> formData() => request.formData();

  @override
  String get integrity => request.integrity;

  @override
  Future<Object> json() => request.json();

  @override
  String get method => request.method;

  @override
  RequestMode get mode => request.mode;

  @override
  RequestRedirect get redirect => request.redirect;

  @override
  String get referrer => request.referrer;

  @override
  ReferrerPolicy get referrerPolicy => request.referrerPolicy;

  @override
  Future<String> text() => request.text();

  @override
  String get url => request.url;
}
