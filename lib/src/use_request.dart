import '_constants.dart';
import 'request.dart';
import 'types.dart';
import 'create_error.dart';

Request useRequest(Event event) {
  return switch (event.get<Request>(kRequest)) {
    Request request => request,
    _ => throw createError('Illegal Event'),
  };
}
