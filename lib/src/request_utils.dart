import '_constants.dart';
import 'headers.dart';
import 'request.dart';
import 'types.dart';
import 'create_error.dart';

Request useRequest(Event event) {
  return switch (event.get<Request>(kRequest)) {
    Request request => request,
    _ => throw createError('Illegal Event'),
  };
}

Headers useHeaders(Event event) => useRequest(event).headers;

String? getClientAddress(Event event) {
  return switch (event.get<String>(kClientAddress)) {
    String value => value,
    _ => null,
  };
}

void setClientAddress(Event event, String address) {
  event.set(kClientAddress, address);
}

Uri useRequestURI(Event event) => useRequest(event).uri;
