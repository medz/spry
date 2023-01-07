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
  Map<String, Object?> get params {
    dynamic params = context.get(SPRY_REQUEST_PARAMS);
    if (params is Map) return params.cast<String, Object?>();

    params = <String, Object?>{};
    context.set(SPRY_REQUEST_PARAMS, params);

    return params as Map<String, Object?>;
  }

  /// Get a request param.
  Object? param(String name) => params[name];
}
