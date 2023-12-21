import 'dart:async';

import 'package:routingkit/routingkit.dart';

import '../request/request.dart';
import '../responder/closure_responder.dart';
import '../responder/responder.dart';
import '../response/response.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderClosure on RoutesBuilder {
  void on<T extends Object?>(
    FutureOr<T> Function(Request request) closure, {
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

extension<T extends Object?> on FutureOr<T> Function(Request) {
  Responder makeResponder() {
    return switch (this) {
      FutureOr<Response> Function(Request) f1 => f1.makeResponder(),
      FutureOr<Responsible> Function(Request) f2 => f2.makeResponder(),
      _ => createJsonResponder(),
    };
  }

  /// Creates a responder that returns a JSON response with the result of the
  /// closure.
  Responder createJsonResponder() {
    return (request) async {
      final result = await this(request);
      final contentType = switch (result) {
        // String
        String _ => 'text/plain; charset=utf-8',
        // other
        _ => 'application/json; charset=utf-8',
      };

      return Response(
        status: 200,
        body: result,
      );
    }.makeResponder();
  }
}

extension on FutureOr<Response> Function(Request) {
  Responder makeResponder() => ClosureResponder(this);
}

extension on FutureOr<Responsible> Function(Request) {
  Responder makeResponder() {
    return (request) async {
      final responsible = await this(request);
      return responsible.toResponse(request);
    }.makeResponder();
  }
}
