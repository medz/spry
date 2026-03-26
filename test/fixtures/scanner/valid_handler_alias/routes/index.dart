// ignore_for_file: prefer_function_declarations_over_variables

import 'package:spry/spry.dart';

typedef AppHandler = Response Function(Event event);

final AppHandler handler = (Event event) => Response('ok');
