import 'dart:async';

import 'package:routingkit/routingkit.dart';
import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';
import '../responder/closure_responder.dart';
import '../responder/responder.dart';

import '../response/responsible.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderClosure on RoutesBuilder {
  void on<T extends Object?>(
    FutureOr<T> Function(RequestEvent event) closure, {
    required String method,
    required String path,
  }) {
    final Route<T> route = Route(
      method: method,
      path: path.pathComponents,
      responder: closure.makeResponder(),
    );

    return this.route(route);
  }
}

extension<T extends Object?> on FutureOr<T> Function(RequestEvent) {
  Responder makeResponder() {
    return switch (this) {
      FutureOr<Response> Function(RequestEvent) f1 => f1.makeResponder(),
      FutureOr<Responsible> Function(RequestEvent) f2 => f2.makeResponder(),
      _ => createJsonResponder(),
    };
  }

  /// Creates a responder that returns a JSON response with the result of the
  /// closure.
  Responder createJsonResponder() {
    return (RequestEvent event) async {
      return Response.json(await this(event));
    }.makeResponder();
  }
}

extension on FutureOr<Response> Function(RequestEvent) {
  Responder makeResponder() => ClosureResponder(this);
}

extension on FutureOr<Responsible> Function(RequestEvent) {
  Responder makeResponder() {
    return (request) async {
      final responsible = await this(request);
      return responsible.toResponse(request);
    }.makeResponder();
  }
}
