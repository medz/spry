import 'package:logging/logging.dart';
import 'package:routingkit/routingkit.dart';
import 'package:webfetch/webfetch.dart';

import '../core/container.dart';
import '../routing/route.dart';
import '../spry.dart';

class RequestEvent {
  /// Current Spry application.
  final Spry application;

  /// Cruuent request event storage container.
  ///
  /// This container only stores the content provided by the current request
  /// event. Especially in middleware, Responder stores content, and the
  /// backend middleware reads it and processes it.
  late final Container container;

  /// Returns the current request route.
  Route? get route => container.get<Route>();

  /// Current request instance.
  final Request request;

  /// Current request event id.
  ///
  /// The id read from the request `x-request-id` header, If the header is not
  /// present, a new id is generated.
  late final String id;

  /// Current request event logger.
  late final Logger logger;

  /// Current request matched route parameters.
  final Parameters parameters = Parameters();

  RequestEvent({
    required this.application,
    required this.request,
    String? id,
    Logger? logger,
  }) {
    id = this.id = switch (id) {
      String value when value.isNotEmpty => value,
      _ => (request.headers.get('x-request-id') ?? '').orGenerateId,
    };
    if (!request.headers.has('x-request-id')) {
      request.headers.set('x-request-id', id);
    }

    this.logger = logger ?? Logger('spry.request.$id');
    container = Container(this.logger);
  }
}

extension on String {
  /// Read or generate a new id.
  String get orGenerateId {
    if (isNotEmpty) return this;

    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}
