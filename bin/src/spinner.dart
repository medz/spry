import 'dart:async';
import 'dart:io';

import 'package:coal/utils.dart';

import 'ansi.dart';

class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  final StringSink _fallback;
  final bool _active;
  Timer? _timer;
  int _frame = 0;
  String _label;

  Spinner._(this._fallback, this._active, this._label);

  static Spinner start(StringSink out, String label) {
    final active = stdout.hasTerminal;
    final s = Spinner._(out, active, label);
    if (active) {
      stdout.write('$cursorHide  ${gray(_frames[0])}  $label');
      unawaited(stdout.flush());
      s._timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
        s._frame = (s._frame + 1) % _frames.length;
        stdout.write(
          '${eraseLines(1)}  ${gray(_frames[s._frame])}  ${s._label}',
        );
        unawaited(stdout.flush());
      });
    } else {
      out.writeln('  $label');
    }
    return s;
  }

  void update(String label) => _label = label;

  void done(String line) => _finish(line);

  void fail(String line) => _finish(line);

  void _finish(String line) {
    _timer?.cancel();
    _timer = null;
    if (_active) {
      stdout.write('${eraseLines(1)}$line\n$cursorShow');
      unawaited(stdout.flush());
    } else {
      _fallback.writeln(line);
    }
  }
}
