import 'dart:async';
import 'dart:io';

import 'ansi.dart';

// Follows the same pattern as mason_logger's Progress implementation:
// - stdout.hasTerminal for detection (not supportsAnsiEscapes)
// - stdout.write() auto-flushes to a terminal — no explicit flush needed
// - \u001b[2K\r to erase the current line and return to column 0
// - synchronous Timer callback (no async/await)
class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
  static const _clearLine = '\u001b[2K\r';
  static const _disableLineWrap = '\x1b[?7l';
  static const _enableLineWrap = '\x1b[?7h';

  final StringSink _fallback;
  final bool _active;
  Timer? _timer;
  int _frame = 0;
  String _label;

  Spinner._(this._fallback, this._active, this._label);

  /// Starts a spinner with the given [label] and returns it.
  static Spinner start(StringSink out, String label) {
    final active = stdout.hasTerminal;
    final s = Spinner._(out, active, label);
    if (active) {
      stdout.write('$_disableLineWrap  ${gray(_frames[0])}  $label');
      s._timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        s._frame = (s._frame + 1) % _frames.length;
        stdout.write(
          '$_clearLine$_disableLineWrap  ${gray(_frames[s._frame])}  ${s._label}',
        );
      });
    } else {
      out.writeln('  $label');
    }
    return s;
  }

  /// Updates the spinner label without stopping it.
  void update(String label) => _label = label;

  /// Stops the spinner and replaces its line with [line] (success).
  void done(String line) => _finish(line);

  /// Stops the spinner and replaces its line with [line] (failure).
  void fail(String line) => _finish(line);

  void _finish(String line) {
    _timer?.cancel();
    _timer = null;
    if (_active) {
      stdout.writeln('$_clearLine$_enableLineWrap$line');
    } else {
      _fallback.writeln(line);
    }
  }
}
