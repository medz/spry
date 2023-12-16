import 'package:logging/logging.dart';

import '../application.dart';

extension ApplicationLogger on Application {
  /// The logger instance of the current application.
  Logger get logger =>
      injectOrProvide(Logger, () => Logger('spry.application'));
}
