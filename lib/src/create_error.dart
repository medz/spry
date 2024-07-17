import 'response.dart';
import 'types.dart';

SpryError createError(String message, [Response? response]) {
  return _SpryErrorImpl(message, response);
}

class _SpryErrorImpl extends Error implements SpryError {
  _SpryErrorImpl(this.message, [this.response]);

  @override
  final String message;

  @override
  final Response? response;
}
