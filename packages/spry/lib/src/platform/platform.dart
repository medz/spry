import 'dart:typed_data';

import '../event/event.dart';
import '../http/headers.dart';
import '../http/response.dart';

/// Spry platform interface.
abstract class Platform<T, R> {
  const Platform();

  /// Gets a client address.
  ///
  /// If platform not support, returns a empty string.
  String getClientAddress(Event event, T request);

  /// Gets a request method.
  String getRequestMethod(Event event, T request);

  /// Gets a request [Uri].
  Uri getRequestURI(Event event, T request);

  /// Gets a request [Headers].
  Headers getRequestHeaders(Event event, T request);

  /// Gets a request body stream.
  Stream<Uint8List>? getRequestBody(Event event, T request);

  /// Respond to a response.
  Future<R> respond(Event event, T request, Response response);
}
