import 'dart:io';

import 'package:logging/logging.dart';

import '../application.dart';
import '../core/provide_inject.dart';
import '../http/headers/cookies.dart';
import '../logging/application_logger.dart';
import '../polyfills/standard_web_polyfills.dart';

part '_internal/headers.dart';
part '_internal/request.dart';

/// Request event, receiving an HTTP request will treat it as an event, and transfer the event to the request handler for processing.
class RequestEvent with ProvideInject {
  final _RequestEventStorage _storage;

  RequestEvent._(this._storage);

  factory RequestEvent({
    required HttpRequest request,
    required List<Cookie> cookies,
    required Application application,
  }) {
    final storage = _RequestEventStorage(
      cookie: Cookies(request.cookies, cookies),
      request: request,
      application: application,
    );

    final event = RequestEvent._(storage);

    // Provide the request event itself.
    event.provide(HttpRequest, () => request);

    return event;
  }

  /// Returns current application instance.
  Application get application => _storage.application;

  /// Get or set cookies related to the current request.
  Cookies get cookie => _storage.cookie;

  /// Returns current application logger.
  Logger get logger => application.logger;

  @override
  T inject<K, T>(K token, [T Function()? orElse]) {
    T global() => application.inject(token, orElse);

    return super.inject(token, global);
  }

  /// The client's IP address.
  ///
  /// **Note**: It only returns the client IP of the currently connected
  /// server, which does not mean the real user IP. If you need to handle
  /// e.g. reverse proxy, you need to use the `X-Forwarded-For` header and
  /// other headers to determine the real user IP.
  String getClientAddress() {
    return _storage.request.connectionInfo?.remoteAddress.host ?? '::1';
  }

  /// The Web API compatible request object.
  Request get request => _storage.request.returnsOrCreate(this);

  /// Response headers Due to some restrictions imposed by Web APIs, some
  /// special request headers cannot always be set, such as `Set-Cookie`.
  /// There are also some special cases where you obtain other resources from
  /// the outside through fetch, and you need to add or overwrite response
  /// headers in other additional code. Then this helper method is very useful.
  void setHeaders(Map<String, String> headers) {
    final records = headers.entries.map((e) => (e.key, e.value));
    for (final (name, value) in records) {
      _storage.request.response.headers.add(name, value);
      request.headers.append(name, value);
    }
  }
}

class _RequestEventStorage {
  final Cookies cookie;
  final HttpRequest request;
  final Application application;

  const _RequestEventStorage({
    required this.cookie,
    required this.request,
    required this.application,
  });
}
