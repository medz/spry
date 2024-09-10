import 'package:spry/src/http/response.dart';

import '../http/request.dart';
import '../types.dart';

/// Creates a new Spry [Event] instance.
Event createEvent<Raw>(
    {required Spry app, required Request request, required Raw raw}) {
  return _EventImpl(app: app, raw: raw, request: request);
}

class _EventImpl<Raw> implements Event {
  _EventImpl({required this.app, required this.raw, required this.request});

  @override
  late final locals = {};

  @override
  final Raw raw;

  @override
  final Request request;

  @override
  final Spry app;

  @override
  late Response response = Response(null, status: 204);
}
