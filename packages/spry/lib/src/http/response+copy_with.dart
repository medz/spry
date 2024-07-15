// ignore_for_file: file_names

import 'dart:typed_data';

import 'headers.dart';
import 'response.dart';

extension ResponseCopyWith on Response {
  /// Copy a [Response]
  Response copyWith({
    int? status,
    String? statusText,
    Headers? headers,
    Stream<Uint8List>? body,
  }) {
    return Response(
      body ?? this.body,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      headers: headers ?? this.headers,
    );
  }
}
