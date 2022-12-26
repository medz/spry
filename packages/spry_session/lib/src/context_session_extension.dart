import 'dart:io';

import 'package:spry/spry.dart';

/// Spry [Context] extension for [HttpSession] management.
extension ContextSessionExtension on Context {
  /// Returns the [HttpSession] for this [Context].
  HttpSession get session => (get(spryHttpRequest) as HttpRequest).session;
}
