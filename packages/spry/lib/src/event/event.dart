import '../http/request.dart';
import '../locals/locals.dart';

abstract interface class Event {
  Locals get locals;
  Request get request;
}

// final class EventImpl implements Event {
//   EventImpl({
//     required this.appLocals,
//     required this.request,
//   });

//   final Locals appLocals;

//   @override
//   late final Locals locals = EventLocals(appLocals);

//   @override
//   final Request request;
// }
