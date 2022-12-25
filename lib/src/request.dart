import 'dart:io';
import 'dart:typed_data';

abstract class Request {
  /// Read the request body.
  Stream<Uint8List> get body;

  /// The headers for the request.
  ///
  /// The returned [HttpHeaders] are immutable.
  HttpHeaders get headers;

  /// The content length of the request body.
  ///
  /// If the content length is not known, this will be -1.
  int get length;

  /// Return the request MIME-type void of parameters such as "charset".
  String? get type;

  /// The method, such as 'GET' or 'POST', for the request.
  String get method;

  /// Return the protocol string "http" or "https" When requested with LTS.
  ///
  /// When the proxy is used, the value of the X-Forwarded-Proto header is used.
  String get protocol;

  /// Shorthand for `protocol == 'https'`.
  bool get secure;

  /// When `spry.proxy` is enabled, parse the X-Forwarded-For ip address.
  Iterable<String> get ips;

  /// Return requests remote address.
  ///
  /// When the proxy is used, the value of the X-Forwarded-For header is used.
  /// and the first address is returned.
  String get ip => ips.first;

  /// Get the charset when present or null.
  String? get charset;

  /// Parse the "Host" header field host and support X-Forwarded-Host when
  /// proxy is enabled.
  String get host;

  /// Get request [Uri].
  Uri get uri;
}
