import 'package:code_builder/code_builder.dart';
import 'package:path/path.dart';

import 'segment.dart';

/// Builder.
class Builder {
  /// The path segment document.
  final Segment segmentDocument;

  /// Root directory.
  final String rootDirectory;

  /// Create a new builder.
  const Builder({
    required this.segmentDocument,
    required this.rootDirectory,
  });

  /// Create a new builder from a directory path.
  factory Builder.fromDirectory(String directory) {
    return Builder(
      segmentDocument: Segment.fromDirectory(directory),
      rootDirectory: directory,
    );
  }

  /// Build a Dart library.
  void call(LibraryBuilder libraryBuilder) {
    final Expression app =
        declareFinal('app', type: refer('Router', 'package:spry/router.dart'))
            .assign(router);

    libraryBuilder.body.add(app.statement);
  }

  /// Get the segment router
  Expression get router {
    Expression router = refer('Router', 'package:spry/router.dart').call([]);

    // Add middleware
    if (segmentDocument.middleware != null) {
      router = router.cascade('use').call([middleware!]);
    }

    // Add parameter middleware.
    for (final MapEntry<String, Reference> entry
        in paramterMiddleware.entries) {
      router = router
          .cascade('param')
          .call([literalString(entry.key, raw: true), entry.value]);
    }

    // Add all verb handler.
    if (segmentDocument.handler != null) {
      router =
          router.cascade('all').call([literalString('/', raw: true), handler!]);
    }

    // Add method handlers.
    for (final MapEntry<String, Expression> entry in methodHandlers.entries) {
      router = router.cascade('route').call([
        literalString(entry.key, raw: true),
        literalString('/', raw: true),
        entry.value,
      ]);
    }

    // Add all child routes.
    router = buildChildRoutes(router);

    return router;
  }

  /// Build child routes
  Expression buildChildRoutes(Expression router) {
    for (final Segment child in segmentDocument.children) {
      String childSegment = basename(child.directory);
      final String? paramName = resolveParamName(childSegment);
      if (paramName != null) {
        childSegment = ':$paramName';
        if (child.configuration?.expression != null) {
          childSegment += child.configuration!.expression!;
        }
      }

      final Builder builder = Builder(
        segmentDocument: child,
        rootDirectory: rootDirectory,
      );
      router = router.cascade('mount').call([
        literalString(childSegment, raw: true)
      ], {
        "router": builder.router,
      });
    }

    return router;
  }

  /// Get all method expressions.
  Map<String, Expression> get methodHandlers {
    final Map<String, Expression> methods = {};

    for (final MapEntry<String, Segment> entry
        in segmentDocument.methodSegments.entries) {
      final Segment segment = entry.value;

      // If the handler is null, throw an error.
      if (segment.handler == null) {
        throw Exception('The handler for the method "${entry.key}" is null.');
      }
      final Builder builder = Builder(
        segmentDocument: segment,
        rootDirectory: rootDirectory,
      );

      Expression handler =
          refer('handler', relative(segment.handler!, from: rootDirectory));

      // Add middleware.
      if (builder.middleware != null) {
        handler = handler.property('use').call([builder.middleware!]);
      }

      // Add parameter middleware.
      for (final MapEntry<String, Reference> entry
          in builder.paramterMiddleware.entries) {
        handler = handler.property('param').call([
          literalString(entry.key, raw: true),
          entry.value,
        ]);
      }

      methods[entry.key] = handler;
    }

    return methods;
  }

  /// Get paramter middleware.
  Map<String, Reference> get paramterMiddleware {
    final Map<String, Reference> middleware = {};

    for (final MapEntry<String, String> entry
        in segmentDocument.paramsMiddleware.entries) {
      middleware[entry.key] =
          refer('middleware', relative(entry.value, from: rootDirectory));
    }

    return middleware;
  }

  /// Get middleware reference.
  Reference? get middleware {
    if (segmentDocument.middleware == null) {
      return null;
    }

    return refer('middleware',
        relative(segmentDocument.middleware!, from: rootDirectory));
  }

  /// Get handler reference.
  Expression? get handler {
    if (segmentDocument.handler == null) {
      return null;
    }

    return refer(
        'handler', relative(segmentDocument.handler!, from: rootDirectory));
  }

  /// Get segment base name.
  String get segmentBaseName => basename(segmentDocument.directory);

  /// Is a dynamic segment.
  String? get segmentParamName => resolveParamName(segmentBaseName);

  /// Resolve param name
  static String? resolveParamName(String segment) {
    return RegExp('^\\[([a-zA-Z0-9_]+)\\]\$').firstMatch(segment)?.group(1);
  }
}
