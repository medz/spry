import 'dart:convert';
import 'dart:typed_data';

import 'http_message.dart';
import 'headers.dart';

/// HTTP request.
abstract interface class Request implements HttpMessage {
  /// Returns the request method.
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

  factory Request({
    required Headers headers,
    required String method,
    required Uri uri,
    Encoding? encoding,
    Stream<Uint8List>? body,
  }) {
    return _RequestImpl(
      method: method,
      uri: uri,
      headers: headers,
      body: body,
      encoding: switch (encoding) {
        Encoding encoding => encoding,
        _ => _getEncodingForTypes(headers.getAll('content-type')),
      },
    );
  }

  static Encoding _getEncodingForTypes(Iterable<String> types) {
    for (final type in types) {
      for (final param in type.split(';')) {
        final kv = param.trim().toLowerCase().split('=');
        if (kv.length == 2 && kv[0].trim() == 'charset') {
          final encoding = Encoding.getByName(kv[1].trim());
          if (encoding != null) {
            return encoding;
          }
        }
      }
    }

    return utf8;
  }
}

class _RequestImpl implements Request {
  const _RequestImpl({
    this.body,
    required this.encoding,
    required this.headers,
    required this.method,
    required this.uri,
  });

  @override
  final Stream<Uint8List>? body;

  @override
  final Encoding encoding;

  @override
  final Headers headers;

  @override
  final String method;

  @override
  final Uri uri;
}
