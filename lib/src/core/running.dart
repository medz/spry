import 'dart:async';

class Running {
  final Completer<void> _completer;

  const Running(Completer<void> completer) : _completer = completer;

  /// Stop the application from running.
  void stop() => _completer.complete();

  /// Wait for the application to stop running.
  Future<void> get onStopped => _completer.future;
}
