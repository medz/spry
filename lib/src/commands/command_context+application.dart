// ignore_for_file: file_names

import 'package:consolekit/consolekit.dart';

import '../spry.dart';

extension CommandContext$Application on CommandContext {
  /// Returns current Spry application.
  Spry get application {
    return switch (userinfo[#spry.application]) {
      Spry app => app,
      _ => throw StateError('Application not set in context.'),
    };
  }

  /// Sets current Spry application.
  set application(Spry app) => userinfo[#spry.application] = app;
}
