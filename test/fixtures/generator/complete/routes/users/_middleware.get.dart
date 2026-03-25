import 'package:spry/spry.dart';

Future<Response> middleware(Event event, Next next) => next();
