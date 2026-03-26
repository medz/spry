import 'package:spry/spry.dart';

Response onError(Object error, StackTrace stackTrace, Event event) =>
    Response('error-get');
