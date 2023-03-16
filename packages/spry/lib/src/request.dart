import 'dart:convert';
import 'dart:io' hide HttpException;

import 'context.dart';
import 'http_exception.dart';

/// A request to Spry.
class Request {
  /// Creates a new [Request] instance.
  const Request({
    required this.context,
    required this.httpRequest,
  });

  /// The [Spry] [Context] instance of current [Request].
  final Context context;

  /// The raw [HttpRequest] instance of current [Request].
  final HttpRequest httpRequest;

  /// The method, such as 'GET' or 'POST', for the request.
  String get method => httpRequest.method;

  /// The URI for the request.
  ///
  /// This provides access to the
  /// path and query string for the request.
  Uri get uri => httpRequest.uri;

  /// The requested URI for the request.
  ///
  /// The returned URI is reconstructed by using http-header fields, to access
  /// otherwise lost information, e.g. host and scheme.
  ///
  /// To reconstruct the scheme, first 'X-Forwarded-Proto' is checked, and then
  /// falling back to server type.
  ///
  /// To reconstruct the host, first 'X-Forwarded-Host' is checked, then 'Host'
  /// and finally calling back to server.
  Uri get requestedUri => httpRequest.requestedUri;

  /// The HTTP protocol version used in the request,
  /// either "1.0" or "1.1".
  String get protocolVersion => httpRequest.protocolVersion;

  /// If `true`, the stream returned by [read] won't emit any bytes.
  ///
  /// This may have false negatives, but it won't have false positives.
  bool get isEmpty => httpRequest.contentLength == 0;

  /// The request headers.
  ///
  /// The returned [HttpHeaders] are immutable.
  HttpHeaders get headers => httpRequest.headers;

  /// The cookies in the request, from the "Cookie" headers.
  Iterable<Cookie> get cookies => httpRequest.cookies;

  /// Read the requested stream body.
  Stream<List<int>> stream() => httpRequest;

  /// Read the request RAW body.
  Future<List<int>> raw() async {
    final List<List<int>> parts = await stream().toList();
    final List<int> raw = parts.expand((List<int> part) => part).toList();

    return raw;
  }

  /// Read the requested text body.
  ///
  /// - [encoding] is the encoding to use when decoding the body.
  /// defaults to [Spry.encoding].
  Future<String> text({Encoding? encoding}) {
    encoding ??= context.app.encoding;

    return raw().then((encoded) => encoding!.decode(encoded)).catchError((e) {
      throw HttpException.internalServerError();
    });
  }
}
