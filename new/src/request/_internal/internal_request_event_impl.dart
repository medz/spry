import 'dart:io';

import 'package:logging/src/logger.dart';
import 'package:routingkit/routingkit.dart';
import 'package:webfetch/src/request.dart';

import '../request_event.dart';
import '../../application.dart';
import '../../http/cookies.dart';
import '../../routing/route.dart';
import '../../utilities/storage.dart';
import 'internal_readonly_request_impl.dart';

class InternalRequestEventImpl implements RequestEvent {
  InternalRequestEventImpl({
    required this.application,
    required HttpRequest httpRequest,
  }) {
    identifier = httpRequest.identifier;
    logger = Logger('spry.request.$identifier');
    storage = Storage(logger);
    cookies = Cookies(httpRequest.cookies, httpRequest.response.cookies);
    request = InternalReadonlyRequestImpl(httpRequest);
    remoteAddress = httpRequest.connectionInfo?.remoteAddress;

    // Sets the HTTP request and response to the storage.
    storage.set(const StorageKey<HttpRequest>(), httpRequest);
    storage.set(const StorageKey<HttpResponse>(), httpRequest.response);
  }

  @override
  final Application application;

  @override
  late final String identifier;

  @override
  late final Cookies cookies;

  @override
  late final Storage storage;

  @override
  late final Request request;

  @override
  late final Logger logger;

  @override
  final Parameters params = Parameters();

  @override
  Route? get route => storage.get(const StorageKey<Route>());
  set route(Route? value) {
    if (value == null) return;

    storage.set(const StorageKey<Route>(), value);
  }

  @override
  late final InternetAddress? remoteAddress;
}

extension on HttpRequest {
  String get identifier => headers.value('x-request-id') ?? generatedIdentifier;

  String get generatedIdentifier =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);
}
