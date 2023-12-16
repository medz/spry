import 'dart:async';

import '../application.dart';
import '../core/container.dart';
import '../http/responder.dart';
import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';

extension ApplicationResponderProperty on Application {
  /// Returns the responder for the application.
  ApplicationResponder get responder {
    final existing = container.get(ApplicationResponder._key);
    if (existing != null) return existing;

    final responder = ApplicationResponder(this);
    container.set(ApplicationResponder._key, value: responder);

    return responder;
  }
}

class ApplicationResponder implements Responder {
  static const _key = ContainerKey<ApplicationResponder>(#spry.responder);

  final Application application;

  ApplicationResponder(this.application) {
    application.container.set(_Storage._storageKey, value: _Storage());
  }

  /// Returns current responder.
  _Storage get _storage => application.container.get(_Storage._storageKey)!;

  /// Returns current responder.
  Responder get current {
    final factory = _storage.factory;
    if (factory == null) {
      throw StateError(
          'No responder configured. Configure with app.responder.use(...)');
    }

    return factory(application);
  }

  /// Use a responder factory.
  void use(Responder Function(Application application) factory) {
    _storage.factory = factory;
  }

  @override
  FutureOr<Response> respond(RequestEvent event) => current.respond(event);
}

class _Storage {
  static const _storageKey = ContainerKey<_Storage>(#spry.responder._storage);

  Responder Function(Application application)? factory;
}
