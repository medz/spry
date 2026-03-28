import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:coal/utils.dart';

import 'ansi.dart';

class Spinner {
  static const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  final StringSink _fallback;
  final bool _active;
  final List<List<Object?>> _pendingMessages = <List<Object?>>[];
  SendPort? _messages;
  bool _finished = false;

  Spinner._(this._fallback, this._active);

  static Spinner start(StringSink out, String label) {
    final active = stdout.hasTerminal;
    final s = Spinner._(out, active);
    if (active) {
      stdout.write('$cursorHide  ${gray(_frames[0])}  $label');
      unawaited(stdout.flush());
      final ready = ReceivePort();
      ready.listen((message) {
        if (message is! SendPort) {
          return;
        }
        s._messages = message;
        for (final pending in s._pendingMessages) {
          message.send(pending);
        }
        s._pendingMessages.clear();
        ready.close();
      });
      unawaited(Isolate.spawn(_runSpinnerIsolate, [ready.sendPort, label]));
    } else {
      out.writeln('  $label');
    }
    return s;
  }

  void update(String label) {
    _send(['update', label]);
  }

  Future<void> done(String line) => _finish(line);

  Future<void> fail(String line) => _finish(line);

  Future<void> _finish(String line) async {
    if (_finished) {
      return;
    }
    _finished = true;
    if (_active) {
      final ack = ReceivePort();
      _send(['finish', line, ack.sendPort]);
      await ack.first;
      ack.close();
    } else {
      _fallback.writeln(line);
    }
  }

  void _send(List<Object?> message) {
    if (!_active) {
      return;
    }
    if (_messages case final port?) {
      port.send(message);
      return;
    }
    _pendingMessages.add(message);
  }

  static void _runSpinnerIsolate(List<Object?> args) {
    final ready = args[0]! as SendPort;
    var label = args[1]! as String;
    var frame = 0;
    final messages = ReceivePort();
    ready.send(messages.sendPort);

    Timer? timer;
    timer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      frame = (frame + 1) % _frames.length;
      stdout.write('${eraseLines(1)}  ${gray(_frames[frame])}  $label');
      unawaited(stdout.flush());
    });

    messages.listen((message) {
      if (message is! List<Object?> || message.isEmpty) {
        return;
      }
      switch (message[0]) {
        case 'update':
          label = message[1]! as String;
        case 'finish':
          timer?.cancel();
          timer = null;
          stdout.write('${eraseLines(1)}${message[1]}\n$cursorShow');
          final done = stdout.flush();
          if (message.length > 2 && message[2] is SendPort) {
            final ack = message[2]! as SendPort;
            unawaited(done.then((_) => ack.send(null)));
          } else {
            unawaited(done);
          }
          messages.close();
      }
    });
  }
}
