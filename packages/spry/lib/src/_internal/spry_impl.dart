part of '../spry.dart';

const String _xPoweredBy = 'x-powered-by';

/// [Spry] implementation.
class _SpryImpl implements Spry {
  Middleware? middleware;

  @override
  final Encoding encoding;

  /// Creates a new [Spry] instance.
  _SpryImpl({
    this.encoding = utf8,
  });

  @override
  void use(Middleware middleware) {
    this.middleware = this.middleware?.use(middleware) ?? middleware;
  }

  @override
  void Function(HttpRequest) call(Handler handler) {
    return (HttpRequest request) async {
      final Context context = ContextImpl.fromHttpRequest(request);

      // Define write response function.
      Future<void> responseWriter() => writeResponse(context, request.response);

      // Store spry app in context.
      context.set(SPRY_APP, this);

      // Store eager response writer in context.
      context.set(eagerResponseWriter, responseWriter);

      // Get final middleware.
      final Middleware middleware = this.middleware ?? emptyMiddleware;

      // Create a run function.
      FutureOr<void> run() async {
        if (context.get(responseIsClosed) == true) {
          return;
        }

        await middleware(context, () => handler(context));

        // Write and close response.
        return responseWriter();
      }

      /// Call middleware.
      return await runZonedGuarded<FutureOr<void>>(run, ((error, stack) async {
        if (context.get(responseIsClosed) == true) {
          return;
        }

        final Response response = context.response;
        response
          ..headers.contentLength = 0
          ..status(_resolveHttpStatusCode(error))
          ..stream(Stream.empty());

        // Write and close response.
        return responseWriter();
      }));
    };
  }

  /// Resolve http status code.
  int _resolveHttpStatusCode(Object error) {
    if (error is HttpException) {
      return error.statusCode;
    }

    return HttpStatus.internalServerError;
  }

  /// Write response.
  Future<void> writeResponse(Context context, HttpResponse response) async {
    if (context.get(responseIsClosed) == true) {
      return;
    }

    final Response spryResponse = context.response;

    // Write status code.
    response.statusCode = spryResponse.statusCode;

    // Wirte x-powered-by.
    if (spryResponse.headers.value(_xPoweredBy) == null) {
      response.headers.set(_xPoweredBy, 'Spry');
    }

    // If no date header is set, set it to now.
    if (spryResponse.headers.date == null) {
      response.headers.date = DateTime.now().toUtc();
    }

    // Write cookies.
    for (final Cookie cookie in spryResponse.cookies) {
      response.headers.add(HttpHeaders.setCookieHeader, cookie.toString());
    }

    // Write body.
    final stream = spryResponse.read();
    if (stream != null) {
      await response.addStream(stream);
    }

    // Close response.
    await response.close();
    context.set(responseIsClosed, true);
  }

  /// Default empty middleware.
  static FutureOr<void> emptyMiddleware(Context context, Next next) => next();

  @override
  Future<HttpServer> listen(Handler handler,
      {Object? address,
      required int port,
      int backlog = 0,
      bool shared = false,
      bool v6Only = false,
      SecurityContext? securityContext,
      bool requestClientCertificate = false}) async {
    final Function httpServerFactory =
        securityContext == null ? HttpServer.bind : HttpServer.bindSecure;
    final List<dynamic> positionalArguments = [
      address ?? InternetAddress.anyIPv4,
      port,
      if (securityContext != null) securityContext,
    ];
    final Map<Symbol, dynamic> namedArguments = {
      #backlog: backlog,
      #shared: shared,
      #v6Only: v6Only,
      if (securityContext != null)
        #requestClientCertificate: requestClientCertificate,
    };

    final HttpServer server = await Function.apply(
        httpServerFactory, positionalArguments, namedArguments);

    server.listen(this(handler));

    return server;
  }
}
