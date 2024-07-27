import '../types.dart';

/// Creates a new [SpryError].
SpryError createError(String message) {
  return _SpryErrorImpl(message);
}

class _SpryErrorImpl extends Error implements SpryError {
  _SpryErrorImpl(this.message);

  @override
  final String message;
}
