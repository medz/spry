import 'dart:io';
import 'dart:developer';

import 'package:path/path.dart';

/// Returns current working executable relative to the current working
/// directory.
String get currentExecutable {
  if (NativeRuntime.buildId != null) {
    return relative(Platform.executable);
  }

  final script = relative(Platform.script.path);
  final executable = basename(Platform.executable);

  return '$executable $script';
}
