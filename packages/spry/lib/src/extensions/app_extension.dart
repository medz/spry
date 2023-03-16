import '../context.dart';
import '../spry.dart';

/// Read the [Spry] application instance from the [Context].
extension ReadSpryApplicationExtension on Context {
  /// Read the [Spry] application instance from the [Context].
  Spry get app => this[Spry];
}
