import 'dart:io';

import 'package:spry/constants.dart';
import 'package:spry/spry.dart';

/// Spry [Context] extension for [HttpSession] management.
extension ContextSessionExtension on Context {
  /// Returns the [HttpSession] for this [Context].
  HttpSession get session => (get(SPRY_HTTP_REQUEST) as HttpRequest).session;
}
