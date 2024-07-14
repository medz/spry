import 'http/request.dart';

abstract interface class Event {
  Request get request;
  abstract Map<String, String> params;
}
