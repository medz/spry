// ignore_for_file: file_names

import 'headers_builder.dart';

extension HeadersBuilderSet on HeadersBuilder {
  /// Set a header that will be overwritten if [name] exists.
  void set(String name, String value) {
    remove(name);
    add(name, value);
  }
}
