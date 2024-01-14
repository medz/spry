import 'dart:async';
import 'dart:io';

abstract interface class Handler<T> {
  FutureOr<T> handle(HttpRequest request);
}
