import 'dart:async';
import 'dart:convert';

import 'package:spry/spry.dart';

import '../constant.dart';

/// Spry [Request]/[Response] JSON middleware.
///
/// Example:
/// ```dart
/// import 'package:spry/spry.dart';
/// import 'package:spry_json/spry_json.dart';
///
/// void main() {
///   // ...
///   spry.use(SpryJson());
///   // ...
/// }
/// ```
class SpryJson extends JsonCodec {
  /// Create a [SpryJson] middleware.
  const SpryJson({super.reviver, super.toEncodable});

  /// Disguised as [Middleware]
  FutureOr<void> call(Context context, Next next) {
    context.set(SPRY_JSON, this);

    return next();
  }

  /// Get the [SpryJson] instance from the [Context].
  ///
  /// ```dart
  /// final SpryJson json = SpryJson.of(context);
  /// ```
  static SpryJson of(Context context) {
    if (context.contains(SPRY_JSON)) {
      return context.get(SPRY_JSON) as SpryJson;
    }

    _defaultInstance ??= SpryJson();
    context.set(SPRY_JSON, _defaultInstance!);

    return _defaultInstance!;
  }

  /// Default [SpryJson] instance.
  static SpryJson? _defaultInstance;
}
