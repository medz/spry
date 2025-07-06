import 'dart:async';
import 'dart:typed_data';

import 'package:oxy/oxy.dart';

import '../locals.dart';
import '../platform.dart'
    if (dart.library.js_interop) '../platform.js.dart'
    as inner;
import '../request.dart';

bool isServerRequest<T extends Request>(T request) {
  return request is ServerRequest || request is _RequestImpl;
}

ServerRequest<Platform> createServerRequest<Platform extends inner.Platform>(
  Platform platform,
  Request request, [
  ServerLocals? locals,
]) {
  if (isServerRequest(request)) {
    return request as ServerRequest<Platform>;
  }

  return _RequestImpl(platform, request, locals ?? ServerLocals());
}

final class _RequestImpl<Platform extends inner.Platform>
    implements ServerRequest<Platform> {
  _RequestImpl(this.platform, this.request, this.locals);

  final Request request;

  @override
  final Platform platform;

  @override
  final ServerLocals locals;

  @override
  String? get ip => platform.requestIP(request);

  @override
  Stream<Uint8List> get body => request.body;

  @override
  bool get bodyUsed => request.bodyUsed;

  @override
  RequestCache get cache => request.cache;

  @override
  RequestCredentials get credentials => request.credentials;

  @override
  Headers get headers => request.headers;

  @override
  String get integrity => request.integrity;

  @override
  bool get keepalive => request.keepalive;

  @override
  String get method => request.method;

  @override
  RequestMode get mode => request.mode;

  @override
  RequestPriority get priority => request.priority;

  @override
  RequestRedirect get redirect => request.redirect;

  @override
  String get referrer => request.referrer;

  @override
  ReferrerPolicy get referrerPolicy => request.referrerPolicy;

  @override
  AbortSignal get signal => request.signal;

  @override
  String get url => request.url;

  @override
  ServerRequest<Platform> clone() =>
      _RequestImpl(platform, request.clone(), locals);

  @override
  Future<Uint8List> bytes() => request.bytes();

  @override
  Future<FormData> formData() => request.formData();

  @override
  Future json() => request.json();

  @override
  Future<String> text() => request.text();

  @override
  void waitUntil<T>(FutureOr<T> future) => platform.waitUntil(future);
}
