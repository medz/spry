import 'context.dart';
import 'request.dart';
import 'response.dart';

abstract interface class RawEvent {
  Context get context;
  Request get request;
  Response get response;
}

extension type const Event._(RawEvent raw) {
  Uri get uri => raw.request.uri;
  String get method => raw.request.method.toUpperCase();
}

Event createRequestEvent(RawEvent raw) => Event._(raw);
