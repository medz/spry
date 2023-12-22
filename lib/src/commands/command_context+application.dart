// ignore_for_file: file_names

import 'package:consolekit/consolekit.dart';

import '../application.dart';

extension CommandContext$Application on CommandContext {
  /// Returns current Spry application.
  Application get application {
    return switch (userinfo[#spry.application]) {
      Application app => app,
      _ => throw StateError('Application not set in context.'),
    };
  }

  /// Sets current Spry application.
  set application(Application app) => userinfo[#spry.application] = app;
}
