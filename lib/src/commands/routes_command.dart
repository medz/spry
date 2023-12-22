import 'dart:async';

import 'package:consolekit/consolekit.dart';
import 'package:routingkit/routingkit.dart';
import 'package:spry/spry.dart';
import 'package:spry/src/commands/command_context+application.dart';

/// Displays all routes registered to the `Application`'s `Router` in an
/// ASCII-formatted table.
///
///     $ dart run bin/main.dart routes
///     +------+------------------+
///     | GET  | /search          |
///     +------+------------------+
///     | GET  | /hash/:string    |
///     +------+------------------+
///
/// A colon preceding a path component indicates a variable parameter. A colon
/// with no text following
/// is a parameter whose result will be discarded.
///
/// The path will be displayed with the same syntax that is used to register a
/// route.
class RoutesCommand extends Command {
  @override
  String? get description => 'Displays all registered routes.';

  @override
  FutureOr<void> run(CommandContext context) async {
    final console = context.console;
    final routes = context.application.routes;
    final includeDescription = routes.any((route) => route.description != null);
    final pathSeparator = '/'.consoleText();

    console.outputASCIITable(routes.map((route) {
      final column = <ConsoleText>[
        route.method.toUpperCase().consoleText(),
      ];

      final pathComponents = route.path.where((element) {
        return switch (element) {
          ConstantPathComponent(constant: final path) => path.isNotEmpty,
          _ => true,
        };
      });

      if (pathComponents.isEmpty) {
        column.add(pathSeparator);
      } else {
        column.add(pathSeparator +
            pathComponents
                .map((e) => e.consoleText())
                .reduce((value, element) => value + pathSeparator + element));
      }

      if (includeDescription) {
        column.add(route.description?.consoleText() ?? ''.consoleText());
      }

      return column;
    }));
  }
}

extension on PathComponent {
  ConsoleText consoleText() {
    return switch (this) {
      ConstantPathComponent path =>
        path.description.consoleText(style: ConsoleStyle.plain),
      _ => description.consoleText(style: ConsoleStyle.info),
    };
  }
}

extension on Console {
  void outputASCIITable(Iterable<Iterable<ConsoleText>> rows) {
    final columnWidths = <int>[];

    // calculate longest columns
    for (final row in rows) {
      for (final (i, col) in row.indexed) {
        if (columnWidths.length <= i) {
          columnWidths.add(0);
        }

        if (col.toString().length > columnWidths[i]) {
          columnWidths[i] = col.toString().length;
        }
      }
    }

    void hr() {
      ConsoleText text = ''.consoleText();
      for (final columnWidth in columnWidths) {
        text += '+'.consoleText();
        text += '-'.consoleText();
        text += ('-' * columnWidth).consoleText();
        text += '-'.consoleText();
      }
      text += '+'.consoleText();
      output(text);
    }

    for (final row in rows) {
      hr();

      ConsoleText text = ''.consoleText();
      for (final (i, col) in row.indexed) {
        text += '| '.consoleText();
        text += col;
        text += (' ' * (columnWidths[i] - col.toString().length)).consoleText();
        text += ' '.consoleText();
      }
      text += '|'.consoleText();
      output(text);
    }

    hr();
  }
}
