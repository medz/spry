import 'dart:convert';
import 'dart:io' hide HttpException;

import '../context.dart';
import '../http_exception.dart';
import '../request.dart';
import '../extensions/app_extension.dart';

class RequestImpl extends Request {
  /// [HttpRequest] instance.
  final HttpRequest request;

  @override
  final Context context;

  /// Creates a new [RequestImpl] instance.
  RequestImpl({
    required this.request,
    required this.context,
  });

  @override
  List<Cookie> get cookies => request.cookies;

  @override
  HttpHeaders get headers => request.headers;

  @override
  bool get isEmpty => request.contentLength == 0;

  @override
  String get method => request.method;

  @override
  String get protocolVersion => request.method;

  @override
  Uri get requestedUri => request.requestedUri;

  @override
  Uri get uri => request.uri;

  @override
  Future<List<int>> raw() async {
    final List<List<int>> parts = await stream().toList();
    final List<int> raw = parts.expand((List<int> part) => part).toList();

    return raw;
  }

  @override
  Future<String> text({Encoding? encoding}) async {
    encoding ??= context.app.encoding;
    final raw = await this.raw();

    try {
      return encoding.decode(raw);
    } catch (e) {
      throw HttpException.badRequest("Invalid encoding");
    }
  }

  @override
  Stream<List<int>> stream() => request;
}
