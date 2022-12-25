import 'request.dart';
import 'response.dart';

abstract class Context {
  /// The request
  Request get request;

  /// The response
  Response get response;
}
