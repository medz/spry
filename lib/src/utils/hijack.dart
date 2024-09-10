import 'dart:async';

import '../types.dart';

const _hijackedMark = #spry.request.hijacked;

/// Whether the request has been hijacked.
bool canHijacked(Event event) => event.locals[_hijackedMark] == true;

Future<void> hijack(FutureOr<void> Function() handler) async {}
