/// The libary for the session management.
library spry.session;

import 'dart:io';

import 'src/context.dart';

extension SprySession on Context {
  /// Returns the [HttpSession] for this [Context].
  HttpSession get session => this[HttpRequest].session;
}
