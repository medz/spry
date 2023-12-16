import 'package:stdweb/stdweb.dart';

/// Errors conforming to this protocol will always be displayed by
/// Spry to the end-user (even in production mode where most errors
/// are silenced).
///
/// ```dart
/// class MyError extends AbortError {
///   MyError() : super(500, reason: 'Something went wrong!');
/// }
///
/// throw MyError();
/// ```
///
/// See `Abort` for a default implementation.
///
/// ```dart
/// throw Abort(500, reason: 'Something went wrong!');
/// ```
abstract class AbortError extends Error {
  /// The HTTP status code this error will return.
  final int status;

  /// The reason for this error.
  final String? reason;

  /// The headers for this error, appended to error responses.
  final Headers? headers;

  AbortError(this.status, {this.headers, this.reason});
}
