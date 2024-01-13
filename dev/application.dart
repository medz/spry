import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '_internal/map+value_of.dart';

class Application {
  final HttpServer server;
  final Map locals;

  const Application._(this.server, {required this.locals});

  factory Application(HttpServer server, {Map? locals}) {
    return Application._(server, locals: locals ?? {});
  }

  /// Returns global encoding.
  Encoding get encoding {
    return locals.valueOf(#spry.encoding, (name) {
      if (name is String?) {
        final encoding = Encoding.getByName(name);
        if (encoding != null) return encoding;
      }

      // Default encoding.
      return utf8;
    });
  }

  /// Sets global encoding.
  set encoding(Encoding encoding) => locals[#spry.encoding] = encoding;

  /// Returns spry application logger.
  Logger get logger {
    return locals.valueOf(#spry.logger, (_) {
      return locals[#spry.logger] = Logger('spry');
    });
  }
}
