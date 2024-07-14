import '../http/request.dart';

abstract interface class Event {
  Map get locals;
  Request get request;
}
