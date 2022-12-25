import 'dart:convert';
import 'dart:io';

import '../response.dart';

class ResponseImpl implements Response {
  @override
  late Encoding encoding;

  /// [HttpResponse] instance.
  final HttpResponse response;

  /// Creates a new [ResponseImpl] instance.
  ResponseImpl(this.response);

  @override
  void add(List<int> data) => response.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      response.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) => response.addStream(stream);

  @override
  Future close() => response.close();

  @override
  Future get done => response.done;

  @override
  Future flush() => response.flush();

  @override
  Future<void> redirect(Uri url,
      {int status = HttpStatus.movedTemporarily}) async {
    response.headers.set(HttpHeaders.locationHeader, url);
    response.statusCode = status;

    // Response body is empty, set default content type and content.
    if (response.contentLength == -1) {
      response.headers.contentType = ContentType.text;
      response.write("Redirecting to $url");
    }

    await response.close();
  }

  @override
  void write(Object? object) => response.write(object);

  @override
  void writeAll(Iterable objects, [String separator = ""]) =>
      response.writeAll(objects, separator);

  @override
  void writeCharCode(int charCode) => response.writeCharCode(charCode);

  @override
  void writeln([Object? object = ""]) => response.writeln(object);

  @override
  int get statusCode => response.statusCode;

  @override
  set statusCode(int statusCode) => response.statusCode = statusCode;

  @override
  HttpHeaders get headers => response.headers;
}
