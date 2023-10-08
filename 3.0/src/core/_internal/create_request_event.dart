import 'dart:io';

import '../../standard_web_polyfills.dart';
import '../cookies.dart';
import 'provide_inject.dart';
import '../request_event.dart';
import 'create_request.dart';

class _RequestEventImpl with ProvideInject implements RequestEvent {
  final ProvideInject _globalProvideInject;
  final Headers _headers;

  @override
  final URL url;

  @override
  final Cookies cookie;

  @override
  final Request request;

  _RequestEventImpl({
    required this.url,
    required this.cookie,
    required this.request,
    required Headers headers,
    required ProvideInject globalProvideInject,
  })  : _globalProvideInject = globalProvideInject,
        _headers = headers;

  @override
  void setHeaders(Map<String, String> headers) {
    headers.forEach((key, value) {
      _headers.append(key, value);
    });
  }

  @override
  String getClientAddress() {
    final HttpRequest request = inject<Type, HttpRequest>(HttpRequest);
    return request.connectionInfo?.remoteAddress.host ?? '::1';
  }

  @override
  T inject<K, T>(K token, [T Function()? orElse]) {
    return super
        .inject(token, () => _globalProvideInject.inject(token, orElse));
  }
}

(RequestEvent, Headers, List<Cookie>) createRequestEvent(
    HttpRequest httpRequest, ProvideInject globalProvideInject) {
  final headers = Headers();
  final request = createRequst(httpRequest);
  final cookies = <Cookie>[];
  final event = _RequestEventImpl(
    url: URL(request.url),
    cookie: Cookies(httpRequest.cookies, cookies),
    request: request,
    headers: headers,
    globalProvideInject: globalProvideInject,
  );

  return (event, headers, cookies);
}
