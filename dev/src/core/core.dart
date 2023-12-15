import 'dart:convert';

import '../application.dart';

class Core {
  Core(this.application);

  String poweredBy = 'Spry';
  Encoding encoding = utf8;

  final Application application;
}

extension CoreApplication on Application {
  Core get core => injectOrProvide(Core, () => Core(this));
}
