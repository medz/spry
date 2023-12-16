import 'package:stdweb/stdweb.dart';

extension RequestProperties on Request {
  /// Returns the request [Uri].
  Uri get uri => Uri.parse(url);
}
