import '_utils.dart';
import 'http/response.dart';
import 'types.dart';

extension MiddlewareOperators on Middleware {
  Middleware operator |(Middleware other) {
    return (event, next) => other(event, () async => this(event, next));
  }

  Handler<Response> operator >(Handler handler) {
    return (event) =>
        this(event, () async => responder(event, await handler(event)));
  }
}
