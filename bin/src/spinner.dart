import 'dart:async';
import 'dart:io';

import 'package:coal/utils.dart';

import 'ansi.dart';

/// A build-phase progress indicator.
///
/// On a TTY, animates in-place using ANSI cursor/erase sequences and Coal's
/// frame strings. On a non-TTY (e.g. test StringBuffer), writes a single
/// static label line to the fallback sink so output is still testable.
class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  final StringSink _fallback;
  final bool _active;
  Timer? _timer;
  int _frame = 0;
  String _label;

  Spinner._(this._fallback, this._active, this._label);

  // stdout is line-buffered — use nonBlocking to write directly to the fd
  // so frames appear immediately without waiting for a newline or flush.
  static IOSink get _ttyOut => stdout.nonBlocking;

  /// Starts a spinner with the given [label] and returns it.
  static Spinner start(StringSink out, String label) {
    final active = stdout.supportsAnsiEscapes;
    final s = Spinner._(out, active, label);
    if (active) {
      _ttyOut.write('$cursorHide  ${gray(_frames[0])}  $label');
      s._timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        s._frame = (s._frame + 1) % _frames.length;
        _ttyOut.write(
          '${eraseLines(1)}  ${gray(_frames[s._frame])}  ${s._label}',
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
      _ttyOut.write('${eraseLines(1)}$line\n$cursorShow');
    } else {
      _fallback.writeln(line);
    }
  }
}
