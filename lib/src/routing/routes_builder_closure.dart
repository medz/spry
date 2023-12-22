import 'dart:async';
import 'dart:typed_data';

import 'package:routingkit/routingkit.dart';
import 'package:webfetch/webfetch.dart';

import '../request/request_event.dart';
import '../responder/closure_responder.dart';
import '../responder/responder.dart';
import '../response/responsible.dart';
import 'route.dart';
import 'routes_builder.dart';

extension RoutesBuilderClosure on RoutesBuilder {
  /// Registers a route that responds to the given [method] and [path] with the
  /// result of the [closure].
  void on<T extends Object?>(
    FutureOr<T> Function(RequestEvent event) closure, {
    required String method,
    required String path,
  }) {
    addRoute(Route(
      method: method,
      path: path.pathComponents,
      responder: closure.makeResponder(),
    ));
  }
}

typedef _Closure<T extends Object?> = FutureOr<T> Function(RequestEvent);

extension<T extends Object?> on _Closure<T> {
  Responder makeResponder() {
    final responder = switch (this) {
      _Closure<Response> closure => ClosureResponder(closure),
      _Closure<Responsible> closure => closure.makeResponder(),
      _Closure<Stream> closure => closure.makeResponder(),
      _ => null,
    };
    if (responder != null) return responder;

    // Default responder for closures returning a value.
    //
    // value parsing when webfetch is updated to support it.
    return ClosureResponder((event) async => Response(await this(event)));
  }
}

extension<T> on _Closure<Stream<T>> {
  Responder makeResponder() {
    final _Closure<Stream<Uint8List>> closure = switch (this) {
      _Closure<Stream<Uint8List>> closure => closure,
      _ => throw UnsupportedError(
          'Cannot create responder for closure returning a stream of $T.'),
    };

    return ClosureResponder((event) async => Response(await closure(event)));
  }
}

extension on _Closure<Responsible> {
  Responder makeResponder() {
    return (RequestEvent event) async {
      final responsible = await this(event);
      return responsible.toResponse(event);
    }.makeResponder();
  }
}
