import '../http/request.dart';
import '../locals/locals.dart';

abstract interface class Event {
  Locals get locals;
  Request get request;
}
