import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spry/src/response.dart';

import '_internal/context_impl.dart';
import '_internal/middleware_extension.dart';
import 'context.dart';
import 'handler.dart';
import 'middleware.dart';

part '_internal/spry_impl.dart';

abstract class Spry {
  /// Creates a new [Spry] instance.
  factory Spry() => _SpryImpl();

  /// Use this to add a [Middleware] to [Spry].
  ///
  /// Example:
  /// ```dart
  /// final spry = Spry();
  /// spry.use(logger);
  /// ```
  void use(Middleware middleware);

  /// Create a [HttpServer] listen handler.
  void Function(HttpRequest) call(Handler handler);
}
