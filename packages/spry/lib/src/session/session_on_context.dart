import '../context.dart';
import 'session.dart';

extension SessionContext on Context {
  /// Returns the request session.
  Session get session => this[Session]!;
}
