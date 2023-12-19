import 'package:consolekit/consolekit.dart';

import '../application.dart';

extension CommandContextApplication on CommandContext {
  /// Returns the application.
  Application get application {
    return switch (userinfo[#spry.application]) {
      Application application => application,
      _ => throw StateError(
          'Application not set on context, Configure with context.application = ...'),
    };
  }

  /// Sets Spry application into command context.
  set application(Application value) => userinfo[#spry.application] = value;
}
