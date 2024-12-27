import 'http/headers.dart';
import 'http/request.dart';
import 'http/response.dart';
import 'http/url_search_params.dart';
import 'locals.dart';
import 'spry.dart';

abstract interface class Event {
  Spry get app;
  Locals get locals;
  Request get request;
  Response get response;

  String get method;
  String get path;
  String get pathname;
  URLSearchParams get query;
  Uri get url;
  Headers get headers;
  String? get ip;
}
