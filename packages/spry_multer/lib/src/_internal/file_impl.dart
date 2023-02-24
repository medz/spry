import 'dart:async';
import 'dart:io';

import '../file.dart';

class FileImpl extends File {
  FileImpl(
    this._stream, {
    required this.contentType,
    required this.filename,
  });

  final Stream<List<int>> _stream;

  @override
  final ContentType contentType;

  @override
  final String filename;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return _stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}
