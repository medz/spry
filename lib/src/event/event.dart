import '../locals/locals.dart';

abstract final class Event {
  Locals get locals;
}

final class EventImpl implements Event {
  EventImpl(Locals appLocals) : locals = EventLocals(appLocals);

  @override
  final Locals locals;
}
