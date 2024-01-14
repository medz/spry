abstract interface class AbortException implements Exception {
  /// The message describing the abort.
  String get message;

  /// The status code of the abort.
  int get status;
}
