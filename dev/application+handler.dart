// ignore_for_file: file_names

import 'dart:io';

import 'package:routingkit/routingkit.dart';

import '_internal/map+value_of.dart';
import '_internal/request.dart';
import 'application+encoding.dart';
import 'application.dart';
import 'exception/abort.dart';
import 'exception/application+exceptions.dart';
import 'exception/exception_source.dart';
import 'handler/handler.dart';
import 'request/request+params.dart';
import 'routing/route.dart';

extension Application$Handler on Application {
  Handler get handler => _handler.call;
}

extension on Application {
  _ApplicationHandler get _handler {
    return locals.valueOf(
      #spry.handler,
      (_) => _ApplicationHandler(this)..initialize(),
    );
  }
}

class _ApplicationHandler {
  final Application application;
  late final Router<(Route, Handler)> router;

  _ApplicationHandler(this.application) {
    application.locals[#spry.handler] = this;
    router = TrieRouter(
      caseSensitive: application.routes.caseSensitive,
      logger: application.logger,
    );
  }

  /// Initializes the router handler.
  void initialize() {
    for (final route in application.routes) {
      final segments = route.path.where((element) {
        if (element is ConstSegment) {
          return element.value.isNotEmpty;
        }

        return true;
      });

      router.register(
        (route, route.handler),
        [ConstSegment(route.method.toUpperCase()), ...segments],
      );
    }
  }

  /// Handler for incoming requests.
  Future<Object?> call(HttpRequest incoming) async {
    final request =
        SpryRequest.from(application: application, request: incoming);
    final response = request.response;
    response.encoding = application.encoding;

    try {
      final (route, handler) = lookup(request);
      request.locals[#spry.request.route] = route;

      final result = await handler(request);

      // Result is null or response is closed, returns it.
      if (result != null || response.isClosed) {
        return result;

        // If result is exception or error, throws it.
      } else if (result is Exception || result is Error) {
        throw result;
      }

      // TODO: add response body
    } catch (error, stackTrace) {
      final source = ExceptionSource(
        exception: error,
        stackTrace: stackTrace,
        responseClosedFactory: () => response.isClosed,
      );

      await application.exceptions.process(source, request);
    } finally {
      await response.safeClose();
    }

    return null;
  }

  /// Lookup the handler for the given request.
  (Route, Handler) lookup(SpryRequest request) {
    final method = request.method.toUpperCase();
    final segments = request.uri.pathSegments;
    final result = router.lookup(
      [method, ...segments],
      request.params,
    );

    if (result == null) {
      throw Abort(HttpStatus.notFound);
    }

    return result;
  }
}
