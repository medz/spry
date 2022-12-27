import 'package:spry/spry.dart';

import '_internal/constants.dart';

/// [Request] params extension.
///
/// ```dart
/// handler(Context context) {
///  final String name = context.request.params['name'];
/// }
/// ```
extension RequestParamsExtension on Request {
  /// Get the request params.
  Map<String, Object?> get params =>
      (context.get(SPRY_REQUEST_PARAMS) ?? {}) as Map<String, Object?>;

  /// Get a request param.
  Object? param(String name) => params[name];
}
