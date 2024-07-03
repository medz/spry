// ignore_for_file: file_names

import '_core_keys.dart';
import 'app.dart';
import 'context.dart';

extension ContextApp on Context {
  App get app => get(kAppInstance);
}
