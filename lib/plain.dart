import 'dart:typed_data';

import 'spry.dart';

class PlainRequest implements Request {
  const PlainRequest({
    required this.method,
    required this.uri,
    required this.headers,
    required this.body,
    this.locals,
  });

  @override
  final String method;

  @override
  final Uri uri;
  @override
  final Iterable<(String, String)> headers;
  @override
  final Stream<Uint8List> body;
  final Map? locals;
}

class PlainResponse implements Response {
  @override
  Stream<Uint8List>? body;

  @override
  int status = 200;

  @override
  String statusText = 'No Content';

  @override
  List<(String, String)> get headers => [];
}

class _PlainRawEvent implements RawEvent {
  const _PlainRawEvent({
    required this.context,
    required this.request,
    required this.response,
  });

  @override
  final Context context;

  @override
  final Request request;

  @override
  final Response response;
}

typedef PlainHandler = Future<PlainResponse> Function(PlainRequest request);

PlainHandler toPlainHandler(App app) {
  return (request) async {
    final response = PlainResponse();
    final raw = _PlainRawEvent(
      context: createEventContext(app, request.locals),
      request: request,
      response: PlainResponse(),
    );
    final event = createRequestEvent(raw);

    await app.handler.handle(event);

    return response;
  };
}

PlainRequest createPlainRequest({
  required String method,
  required Uri uri,
  Iterable<(String, String)>? headers,
  Stream<Uint8List>? body,
  Map? locals,
}) {
  return PlainRequest(
    method: method,
    uri: uri,
    headers: headers ?? const [],
    body: body ?? Stream.empty(),
    locals: locals,
  );
}
