// ignore_for_file: file_names

import 'headers.dart';
import 'headers_builder.dart';

extension HeadersToBuilder on Headers {
  /// Creates a [HeadersBuilder] using the current [Headers].
  HeadersBuilder toBuilder() => HeadersBuilder(this);
}
