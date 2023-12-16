import '../polyfills/standard_web_polyfills.dart';
import '../request/redirect.dart';
import 'abort_error.dart';

class Abort extends AbortError {
  Abort(super.status, {super.headers, super.reason});

  factory Abort.redirect(String location,
      [Redirect redirect = Redirect.seeOther]) {
    final headers = Headers({'Location': location});

    return Abort(redirect.status, headers: headers);
  }
}
