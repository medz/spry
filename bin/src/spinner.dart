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

  /// Starts a spinner with the given [label] and returns it.
  ///
  /// On TTY: shows the first frame and starts the animation loop, flushing
  /// stdout after each write so frames appear immediately (IOSink buffers
  /// otherwise and nothing is visible until the buffer fills or the program
  /// exits).
  ///
  /// On non-TTY: writes a single static label line to [out].
  static Future<Spinner> start(StringSink out, String label) async {
    final active = stdout.supportsAnsiEscapes;
    final s = Spinner._(out, active, label);
    if (active) {
      stdout.write('$cursorHide  ${gray(_frames[0])}  $label');
      await stdout.flush();
      s._timer = Timer.periodic(const Duration(milliseconds: 80), (_) async {
        s._frame = (s._frame + 1) % _frames.length;
        stdout.write(
          '${eraseLines(1)}  ${gray(_frames[s._frame])}  ${s._label}',
        );
        await stdout.flush();
      });
    } else {
      out.writeln('  $label');
    }
    return s;
  }

  /// Updates the spinner label without stopping it.
  void update(String label) => _label = label;

  /// Stops the spinner and replaces its line with [line] (success).
  Future<void> done(String line) => _finish(line);

  /// Stops the spinner and replaces its line with [line] (failure).
  Future<void> fail(String line) => _finish(line);

  Future<void> _finish(String line) async {
    _timer?.cancel();
    _timer = null;
    if (_active) {
      stdout.write('${eraseLines(1)}$line\n$cursorShow');
      await stdout.flush();
    } else {
      _fallback.writeln(line);
    }
  }
}
