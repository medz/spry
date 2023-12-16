import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:routingkit/routingkit.dart';

import '../application.dart';
import '../core/container.dart';
import '../http/headers/cookies.dart';
import '../polyfills/standard_web_polyfills.dart';
import '../routing/route.dart';

part '_internal/headers.dart';
part '_internal/request.dart';

const _cookieStoreKey = ContainerKey<Cookies>(#spry.request.event.cookie);

/// Request event, receiving an HTTP request will treat it as an event, and transfer the event to the request handler for processing.
class RequestEvent {
  final Application application;
  final Container container;

  /// Internal http request.
  final HttpRequest _httpRequest;

  RequestEvent._({
    required this.application,
    required this.container,
    required HttpRequest request,
  }) : _httpRequest = request;

  factory RequestEvent({
    required HttpRequest request,
    required List<Cookie> cookies,
    required Application application,
    Logger? logger,
  }) {
    final container = Container(logger: logger ?? Logger('spry.request.event'));
    container.set(_cookieStoreKey, value: Cookies(request.cookies, cookies));

    return RequestEvent._(
      application: application,
      container: container,
      request: request,
    );
  }

  /// Current request route.
  late Route route;

  /// The Web API compatible request object.
  Request get request => _httpRequest.returnsOrCreate(container);

  /// A unique ID for the request event.
  ///
  /// The request identifier is set to value of the `X-Request-Id` header when
  /// present, or to a uniquelly generated value otherwise.
  String get id {
    final id = request.headers.get('x-request-id');
    if (id != null) return id;

    const requestIdKey = ContainerKey<String>(#spry.request.event.id);
    if (container.contains(requestIdKey)) {
      return container.get(requestIdKey)!;
    }

    // Generate a new ID.
    final bytes = List<int>.generate(16, (_) => Random().nextInt(256));
    final generated = base64.encode(bytes);

    // Store the ID in the container.
    container.set(requestIdKey, value: generated);

    return generated;
  }

  /// Get or set cookies related to the current request.
  Cookies get cookie => container.get(_cookieStoreKey)!;

  /// Returns current application logger.
  Logger get logger => application.logger;

  /// Returns current request event parameters.
  Parameters get parameters {
    const key = ContainerKey<Parameters>(#spry.request.event.parameters);
    final existing = container.get(key);
    if (existing != null) return existing;

    final parameters = Parameters();
    container.set(key, value: parameters);

    return parameters;
  }

  /// The client's IP address.
  ///
  /// **Note**: It only returns the client IP of the currently connected
  /// server, which does not mean the real user IP. If you need to handle
  /// e.g. reverse proxy, you need to use the `X-Forwarded-For` header and
  /// other headers to determine the real user IP.
  String getClientAddress() {
    return _httpRequest.connectionInfo?.remoteAddress.host ?? '::1';
  }

  /// Response headers Due to some restrictions imposed by Web APIs, some
  /// special request headers cannot always be set, such as `Set-Cookie`.
  /// There are also some special cases where you obtain other resources from
  /// the outside through fetch, and you need to add or overwrite response
  /// headers in other additional code. Then this helper method is very useful.
  void setHeaders(Map<String, String> headers) {
    final records = headers.entries.map((e) => (e.key, e.value));
    for (final (name, value) in records) {
      _httpRequest.response.headers.add(name, value);
      request.headers.append(name, value);
    }
  }
}
