import 'dart:async';
import 'dart:io';

import '_internal/create_request_event.dart';
import 'handler.dart';
import '_internal/provide_inject.dart';

final class Spry with ProvideInject {
  final Handler handler;
  final String? poweredBy;

  Spry(this.handler, {this.poweredBy}) {
    provide(Spry, () => this);
  }

  FutureOr<dynamic> call(HttpRequest request) async {
    final httpResponse = request.response;

    provide(HttpRequest, () => request);
    provide(HttpResponse, () => httpResponse);

    final (requestEvent, overrideHeaders, cookies) =
        createRequestEvent(request, this);
    final response = await handler(requestEvent);

    // Global headers override local headers
    overrideHeaders.forEach((value, name, parent) {
      response.headers.append(name, value);
    });

    // Move set-cookie headers to cookies
    response.headers.getSetCookie().forEach((setCookie) {
      cookies.add(Cookie.fromSetCookieValue(setCookie));
    });
    overrideHeaders.getSetCookie().forEach((setCookie) {
      cookies.add(Cookie.fromSetCookieValue(setCookie));
    });

    // Write cookies to response
    for (final cookie in cookies) {
      httpResponse.cookies.add(cookie);
    }

    // Write headers to response
    response.headers.forEach((value, name, parent) {
      httpResponse.headers.add(name, value);
    });

    // Write status code to response
    httpResponse.statusCode = response.status;

    // Write content type to response
    // httpResponse.headers.contentType = response.headers.has('content-type')
    //     ? ContentType.parse(response.headers.get('content-type')!)
    //     : ContentType.text;

    // Add powered by header
    httpResponse.headers.removeAll('x-powered-by');
    httpResponse.headers.add('x-powered-by', poweredBy ?? 'Spry');

    // Write body to response
    await httpResponse.addStream(response.body);

    return httpResponse.close();
  }
}

void main() {}
