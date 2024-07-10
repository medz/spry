import 'http_message/http_message.dart';

/// Spry request interface.
abstract interface class Request implements HttpMessage {
  /// The request method of the client.
  String get method;

  /// The requested URI for the request event.
  ///
  /// If the request URI is absolute (e.g. 'https://www.example.com/foo') then
  /// it is returned as-is. Otherwise, the returned URI is reconstructed by
  /// using the request URI path (e.g. '/foo') and HTTP header fields.
  ///
  /// To reconstruct the scheme, the 'X-Forwarded-Proto' header is used. If it
  /// is not present then the socket type of the connection is used i.e. if
  /// the connection is made through a [SecureSocket] then the scheme is
  /// 'https', otherwise it is 'http'.
  ///
  /// To reconstruct the host, the 'X-Forwarded-Host' header is used. If it is
  /// not present then the 'Host' header is used. If neither is present then
  /// the host name of the server is used.
  Uri get uri;
}
