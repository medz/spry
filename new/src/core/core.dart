import 'package:consolekit/consolekit.dart';
import 'package:consolekit/terminal.dart';
import 'package:meta/meta.dart';

import '../application.dart';
import '../commands/boot_command.dart';
import '../utilities/storage.dart';
import 'running.dart';

extension ApplicationCoreProperties on Application {
  /// Internal storage key for the application core.
  @internal
  ApplicationCore get core {
    final existing = storage.get(const _CoreKey());
    if (existing != null) return existing;

    return storage.set(const _CoreKey(), ApplicationCore(application: this));
  }

  /// Returns the application running.
  ApplicationRunning? get running => core._storage.running.current;

  /// Sets the application running.
  set running(ApplicationRunning? value) =>
      core._storage.running.current = value;

  /// Returns the application console.
  Console get console => core._storage.console;

  /// Sets the application console.
  set console(Console value) => core._storage.console = value;

  /// Returns the application commands.
  Commands get commands => core._storage.commands;

  /// Sets the application commands.
  set commands(Commands value) => core._storage.commands = value;
}

class ApplicationCore {
  final Application application;

  const ApplicationCore({required this.application});

  /// Initializes the application core.
  void initialize() {
    application.storage.set(const _Key(), _Storage());
  }

  /// Returns the application core storage.
  _Storage get _storage {
    final existing = application.storage.get(const _Key());
    if (existing == null) {
      throw StateError(
          'Core not configured. Configure with app.core.initialize()');
    }

    return existing;
  }
}

class _Storage {
  Console console;
  Commands commands;
  ApplicationRunningStorage running;

  _Storage()
      : console = Terminal(),
        commands = Commands(),
        running = ApplicationRunningStorage() {
    commands.use('boot', BootCommand());
  }
}

typedef _Key = StorageKey<_Storage>;
typedef _CoreKey = StorageKey<ApplicationCore>;
