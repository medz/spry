import 'dart:async';

class ApplicationRunning {
  final Completer<void> _completer;

  const ApplicationRunning(Completer<void> completer) : _completer = completer;

  /// Stop the application from running.
  void stop() => _completer.complete();

  /// Wait for the application to stop running.
  Future<void> get onStopped => _completer.future;
}

class ApplicationRunningStorage {
  ApplicationRunning? current;

  ApplicationRunningStorage() : current = null;
}
