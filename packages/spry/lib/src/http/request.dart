import 'http_message/http_message.dart';

abstract interface class Request implements HttpMessage {
  String get method;
  Uri get uri;
}
