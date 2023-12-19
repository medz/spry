import 'dart:io';

typedef HTTPHeaders = HttpHeaders;

extension DebugHTTPHeaders on HTTPHeaders {
  /// Returns http headers as a string.
  String toDebugString() {
    final sb = StringBuffer();
    forEach((name, values) {
      sb.writeln('$name: ${values.join(', ')}');
    });
    return sb.toString();
  }
}
