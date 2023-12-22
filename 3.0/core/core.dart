import 'package:consolekit/consolekit.dart';
import 'package:consolekit/terminal.dart';

import '../spry.dart';
import 'running.dart';

extension Core on Spry {
  /// Returns the application running.
  Running? get running => container.get<Running>();

  /// Sets the application running.
  set running(Running? value) {
    if (value == null) return container.remove<Running>();
    container.set(value, onShutdown: (running) => running.stop());
  }

  /// Returns the application console.
  Console get console {
    final existing = container.get<Console>();
    if (existing != null) return existing;

    final console = Terminal();
    container.set<Console>(console);

    return console;
  }

  /// Sets the application console.
  set console(Console value) => container.set<Console>(value);

  /// Returns the application commands.
  Commands get commands {
    final existing = container.get<Commands>();
    if (existing != null) return existing;

    final commands = Commands();
    container.set<Commands>(commands);

    return commands;
  }

  /// Sets the application commands.
  set commands(Commands value) => container.set<Commands>(value);
}
