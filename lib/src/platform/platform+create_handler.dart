// ignore_for_file: file_names

import '../event/event.dart';
import '../spry.dart';
import '../utils/_spry_internal_utils.dart';
import 'platform.dart';
import 'platform_handler.dart';

extension PlatformAdapterCreateHandler<T, R> on Platform<T, R> {
  PlatformHandler<T, R> createHandler(Spry app) {
    final handle = app.createHandle();

    return (T request) async {
      final event = EventImpl(app.locals);
      final response = await handle(event);

      return respond(event, request, response);
    };
  }
}
