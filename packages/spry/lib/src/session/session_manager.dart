import 'dart:io';

import '../context.dart';
import '../middleware.dart';
import '../request.dart';
import 'internal/identifier.dart';
import 'internal/info.dart';
import 'memory_session_adapter.dart';
import 'session.dart';
import 'session_adapter.dart';
import 'types.dart';

class SessionManager {
  /// Default session name.
  static const String defaultSessionName = 'SPRY_SESSION_ID';

  const SessionManager({
    this.adapter = const MemorySessionAdapter(),
    this.name = defaultSessionName,
    this.domain,
    this.path,
    this.secure = false,
    this.httpOnly = true,
    this.identifierGenerator = generateIdentifier,
  });

  /// The session adapter.
  final SessionAdapter adapter;

  /// The cookie name.
  ///
  /// Default: [defaultSessionName]
  final String name;

  /// The domain that the cookie applies to.
  final String? domain;

  /// The path within the [domain] that the cookie applies to.
  final String? path;

  /// Whether to only send this cookie on secure connections.
  final bool secure;

  /// Whether the cookie is only sent in the HTTP request and is not made
  /// available to client side scripts.
  final bool httpOnly;

  /// A session identifier generator.
  final SessionIdentifierGenerator identifierGenerator;

  /// As the session manager is a [Spry] middleware, it must implement the
  /// [call] method.
  Future<void> call(Context context, Next next) async {
    // Store the session manager in the context.
    context[SessionManager] = this;

    // Resolve the session identifier.
    final info = await findOrCreateIdentifierInfo(context.request);

    /// Create a session.
    final session = Session(adapter: adapter, info: info);

    // Store the session in the context.
    context[Session] = session;

    // Calls the next middleware.
    await next();

    print(info.renewed);

    // Send the session cookie.
    if (info.renewed) {
      final cookie = await createCookie(session);
      context.response.cookies.add(cookie);
    }
  }

  /// Create a cookie from the session.
  Future<Cookie> createCookie(Session session) async {
    final cookie = Cookie(name, session.identifier)
      ..domain = domain
      ..path = path
      ..secure = secure
      ..httpOnly = httpOnly;

    final DateTime? expiresAt = await adapter.expiresAt(session.identifier);
    if (expiresAt != null) {
      cookie.expires = expiresAt;
      cookie.maxAge = expiresAt.difference(DateTime.now()).inSeconds;
    }

    return cookie;
  }

  /// Find or create a session identifier.
  Future<Info> findOrCreateIdentifierInfo(Request request) async {
    final info = Info(
      identifierGenerator: identifierGenerator,
      identifier: await identifierGenerator(),
    );

    for (final cookie in request.cookies) {
      if (cookie.name == name && await adapter.can(cookie.value)) {
        return info..identifier = cookie.value;
      }
    }

    return info..renewed = true;
  }
}
