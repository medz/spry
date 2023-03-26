import 'dart:io';

import 'package:mime/mime.dart';
import 'package:path/path.dart' hide Context;
import 'package:prexp/prexp.dart';
import 'package:spry/spry.dart';

const String __spryStaticPrefix = '__spry_static';

/// Spry static
class Static {
  /// Directories to serve static files from.
  final Iterable<String> directories;

  /// Default file to serve when a directory is requested.
  final Iterable<String> defaultFiles;

  /// Path matcher.
  final PathMatcher matcher;

  /// Create a new static from raw parameters.
  const Static.raw({
    required this.directories,
    required this.matcher,
    this.defaultFiles = const <String>[],
  });

  /// Create a new static
  factory Static({
    required Iterable<String> directories,
    String? prefix,
    Iterable<String> defaultFiles = const <String>[],
  }) {
    // Create prefix path
    final String path = "${prefix ?? ''}/:$__spryStaticPrefix*";

    // Create path matcher
    final PathMatcher matcher = PathMatcher.fromPrexp(Prexp.fromString(path));

    return Static.raw(
      directories: directories,
      matcher: matcher,
      defaultFiles: defaultFiles,
    );
  }

  /// Create a new static from a directory.
  factory Static.directory({
    required String directory,
    Iterable<String> defaultFiles = const <String>[],
    String? prefix,
  }) =>
      Static(
        directories: [directory],
        defaultFiles: defaultFiles,
        prefix: prefix,
      );

  /// Handle a spry request.
  Future<void> call(Context context) async {
    final String? path = _resolvePath(context);
    final File? file = _resolveFile(path);

    if (file == null) {
      throw SpryHttpException.notFound();
    }

    // Read file headers
    final List<int> headers =
        await file.openRead(0, 256).toList().then((value) => value.first);

    final String mimeType = lookupMimeType(file.path, headerBytes: headers) ??
        ContentType.binary.mimeType;
    final ContentType contentType = ContentType.parse(mimeType);

    final Response response = context.response;
    response.contentType = contentType;
    response.stream(file.openRead());
  }

  /// As the static to a spry middleware.
  ///
  /// [rear] - Whether to add the handler to the rear of the middleware chain.
  Middleware toMiddleware({bool rear = false}) {
    return (Context context, Next next) async {
      if (rear) await next();

      try {
        final Response response = context.response;
        await call(context);
        response.close();
      } on SpryHttpException catch (e) {
        if (e.statusCode == HttpStatus.notFound && !rear) {
          return await next();
        }

        rethrow;
      }
    };
  }

  /// Resolve a file from a path.
  File? _resolveFile(String? path) {
    for (final String directory in directories) {
      final String filePath = join(directory, path ?? '');
      final File file = File(filePath);
      if (file.existsSync()) {
        return file;
      }

      for (final String defaultFilename in defaultFiles) {
        final String defaultFilePath = join(filePath, defaultFilename);
        final File defaultFile = File(defaultFilePath);
        if (defaultFile.existsSync()) {
          return defaultFile;
        }
      }
    }

    return null;
  }

  /// Resolve a file path
  String? _resolvePath(Context context) {
    final String path = context.request.uri.path;
    final Iterable<PrexpMatch> matches = matcher(path);

    if (matches.isEmpty) {
      return null;
    }

    final PrexpMatch match = matches.first;
    final Object? paths = match.params[__spryStaticPrefix];

    if (paths is Iterable) {
      return joinAll(paths.map((path) => path.toString()));
    }

    return paths?.toString();
  }
}
