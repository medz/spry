// ignore_for_file: file_names

import 'headers.dart';
import 'headers_builder.dart';
import 'headers+to_builder.dart';

extension HeadersRebuild on Headers {
  /// Rebuilding the [Headers] object
  Headers rebuild(void Function(HeadersBuilder builder) updates) {
    final builder = toBuilder();
    updates(builder);

    return builder.toHeaders();
  }
}
