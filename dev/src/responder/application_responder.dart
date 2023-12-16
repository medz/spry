import 'dart:async';

import '../application.dart';
import '../core/storage.dart';
import '../http/responder.dart';
import '../polyfills/standard_web_polyfills.dart';
import '../request/request_event.dart';

extension ApplicationResponderProperty on Application {
  /// Returns the responder for the application.
  ApplicationResponder get responder =>
      injectOrProvide(ApplicationResponder, () => ApplicationResponder(this));
}

class ApplicationResponder implements Responder {
  final Application application;

  ApplicationResponder(this.application) {
    application.provide(_StorageKey, () => _Storage());
  }

  /// Returns current responder.
  _Storage get _storage => application.inject(
      _StorageKey, () => throw StateError('Responder not configured'));

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
  Responder Function(Application application)? factory;
}

class _StorageKey extends StorageKey<_Storage> {
  _StorageKey() : super(#spry.responder);
}
