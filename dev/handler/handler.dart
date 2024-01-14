import 'dart:async';
import 'dart:io';

typedef Handler<T> = FutureOr<T> Function(HttpRequest request);
