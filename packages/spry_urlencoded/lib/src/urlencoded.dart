import 'dart:async';
import 'dart:convert';

import 'package:spry/spry.dart';

/// Spry urlencoded middleware.
class Urlencoded {
  /// The [Urlencoded] instance stored in the [Context] key.
  static const String key = 'spry.urlencoded';

  /// Default [Urlencoded] instance.
  static Urlencoded? _instance;

  /// Each key and value in the returned map has been decoded. If the request
  /// is the empty string, an empty map is returned.
  final Encoding encoding;

  /// @internal, Create a new [Urlencoded] instance.
  const Urlencoded._internal({required this.encoding});

  /// Create a new [Urlencoded] instance.
  factory Urlencoded({Encoding? encoding}) {
    return Urlencoded._internal(encoding: encoding ?? utf8);
  }

  /// Cast the [Urlencoded] instance to a [Middleware].
  FutureOr<void> call(Context context, Next next) {
    context.set(key, this);

    return next();
  }

  /// Get the [Urlencoded] instance from the [Context].
  static Urlencoded of(Context context) {
    if (context.contains(key)) {
      return context[key] as Urlencoded;
    }

    return _instance ??= Urlencoded();
  }
}
