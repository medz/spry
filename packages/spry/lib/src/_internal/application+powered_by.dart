// ignore_for_file: file_names

import '../application.dart';

extension Application$PowerdBy on Application {
  void configurationPoweredBy() {
    final value = poweredBy ?? 'Spry/${Application.version}';

    server.defaultResponseHeaders.set('x-powered-by', value);
  }
}
