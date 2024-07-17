import 'dart:io';

import 'spry.dart';

Future<void> Function(HttpRequest request) toIOHandler(Spry app) {
  final handler = toHandler(app);

  return (httpRequest) async {
    final spryRequest = Request(
      method: httpRequest.method,
      uri: httpRequest.requestedUri,
      headers: _createSpryHeaders(httpRequest.headers),
      body: httpRequest,
    );
    final event = createEvent(app, spryRequest);
    final spryResponse = await handler(event);
    final httpResponse = httpRequest.response;

    httpResponse.statusCode = spryResponse.status;
    httpResponse.reasonPhrase = spryResponse.statusText;

    for (final (name, value) in spryResponse.headers) {
      httpResponse.headers.add(name, value, preserveHeaderCase: true);
    }

    if (spryResponse.body != null) {
      await httpResponse.addStream(spryResponse.body!);
    }

    await httpResponse.close();
  };
}

Headers _createSpryHeaders(HttpHeaders httpHeaders) {
  final inner = Headers();
  httpHeaders.forEach((name, values) {
    for (final value in values) {
      inner.add(name, value);
    }
  });

  return inner;
}
