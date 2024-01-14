import 'dart:convert';
import 'dart:io';

import '../application.dart';
import '../exception/abort.dart';

class SpryResponse implements HttpResponse {
  final HttpResponse response;
  final Application application;

  SpryResponse({
    required this.response,
    required this.application,
  });

  factory SpryResponse.of(HttpResponse response) {
    if (response is SpryResponse) return response;

    throw Abort(
      HttpStatus.internalServerError,
      message:
          'The response magic only runs within the Spry framework and cannot be accessed by regular HTTP responses.',
    );
  }

  bool _isClosed = false;

  /// Whether the response is closed.
  bool get isClosed => _isClosed;

  /// Safely closes the response.
  Future safeClose() async {
    if (!isClosed) {
      return await close();
    }
  }

  @override
  bool get bufferOutput => response.bufferOutput;

  @override
  set bufferOutput(bool bufferOutput) => response.bufferOutput = bufferOutput;

  @override
  int get contentLength => response.contentLength;

  @override
  set contentLength(int contentLength) =>
      response.contentLength = contentLength;

  @override
  Duration? get deadline => response.deadline;

  @override
  set deadline(Duration? deadline) => response.deadline = deadline;

  @override
  Encoding get encoding => response.encoding;

  @override
  set encoding(Encoding encoding) => response.encoding = encoding;

  @override
  bool get persistentConnection => response.persistentConnection;

  @override
  set persistentConnection(bool persistentConnection) =>
      response.persistentConnection = persistentConnection;

  @override
  String get reasonPhrase => response.reasonPhrase;

  @override
  set reasonPhrase(String reasonPhrase) => response.reasonPhrase = reasonPhrase;

  @override
  int get statusCode => response.statusCode;

  @override
  set statusCode(int statusCode) => response.statusCode = statusCode;

  @override
  void add(List<int> data) => response.add(data);

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      response.addError(error, stackTrace);

  @override
  Future addStream(Stream<List<int>> stream) => response.addStream(stream);

  @override
  Future close() {
    _isClosed = true;

    return response.close();
  }

  @override
  HttpConnectionInfo? get connectionInfo => response.connectionInfo;

  @override
  List<Cookie> get cookies => response.cookies;

  @override
  Future<Socket> detachSocket({bool writeHeaders = true}) {
    _isClosed = true;

    return response.detachSocket(writeHeaders: writeHeaders);
  }

  @override
  Future get done => response.done;

  @override
  Future flush() => response.flush();

  @override
  HttpHeaders get headers => response.headers;

  @override
  Future redirect(Uri location, {int status = HttpStatus.movedTemporarily}) {
    _isClosed = true;

    return response.redirect(location, status: status);
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
}
