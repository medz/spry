import '../application.dart';
import '../utilities/storage.dart';

class RequestEvent {
  RequestEvent(this.application);

  /// The application that received the request.
  final Application application;

  /// Current request event storage.
  final Storage storage = Storage();

  /// Current event request identifier.
  // String get id {}
}
