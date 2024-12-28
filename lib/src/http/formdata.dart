import 'dart:convert';
import 'dart:typed_data';

import 'package:mime/mime.dart' show MimeMultipartTransformer;
import 'package:path/path.dart' show basename;

import '_utils.dart';
import 'cross_file.dart';
import 'headers.dart';

const _lineTerminatorStr = '\r\n';

sealed class FormDataEntry {
  const FormDataEntry(this.name);
  final String name;
  int get lengthInBytes;
}

final class FormDataString extends FormDataEntry {
  const FormDataString(super.name, this.value);
  final String value;

  @override
  int get lengthInBytes => throw UnimplementedError();
}

final class FormDataFile extends FormDataEntry implements CrossFile {
  FormDataFile(
    super.name,
    String path, {
    String? mimeType,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  }) : _file = CrossFile(path,
            name: basename(path),
            mimeType: mimeType,
            length: length,
            bytes: bytes,
            lastModified: lastModified);

  FormDataFile.fromData(
    super.name,
    Uint8List bytes, {
    String? mimeType,
    int? length,
    String? path,
    DateTime? lastModified,
  }) : _file = CrossFile.fromData(
          bytes,
          name: path != null ? basename(path) : name,
          path: path,
          mimeType: mimeType,
          length: length,
          lastModified: lastModified,
        );

  FormDataFile.fromFile(super.name, CrossFile file) : _file = file;

  final CrossFile _file;

  @override
  Future<DateTime> lastModified() => _file.lastModified();

  @override
  Future<int> length() => _file.length();

  @override
  String? get mimeType => _file.mimeType;

  @override
  Stream<Uint8List> openRead([int? start, int? end]) =>
      _file.openRead(start, end);

  @override
  String get path => _file.path;

  @override
  Future<Uint8List> readAsBytes() => _file.readAsBytes();

  @override
  Future<String> readAsString({Encoding encoding = utf8}) =>
      _file.readAsString(encoding: encoding);

  @override
  Future<void> saveTo(String path) => _file.saveTo(path);

  @override
  // TODO: implement lengthInBytes
  int get lengthInBytes => throw UnimplementedError();
}

extension type FormData._(List<FormDataEntry> entries)
    implements List<FormDataEntry> {
  factory FormData([Iterable<FormDataEntry>? init]) {
    final form = FormData._([]);
    if (init != null && init.isNotEmpty) {
      for (final entry in init) {
        form.add(entry);
      }
    }

    return form;
  }

  Stream<Uint8List> toStream(String boundary) async* {
    final separator = utf8.encode('--$boundary$_lineTerminatorStr');
    for (final entry in this) {
      yield separator;
      yield* switch (entry) {
        FormDataString entry => _createStringEntryStream(entry),
        FormDataFile file => _createFileEntryStream(file),
      };
    }

    yield utf8.encode('--$boundary--$_lineTerminatorStr');
  }

  static Future<FormData> parse({
    required String boundary,
    required Stream<Uint8List> stream,
  }) async {
    final form = FormData();
    final transformer = MimeMultipartTransformer(boundary).bind(stream);
    await for (final part in transformer) {
      final headers = Headers(part.headers);
      final disposition = headers.get('content-disposition');
      final name = getHeaderSubParam(disposition, 'name');
      if (name == null) continue;

      final bytes = <int>[];
      await for (final chunk in part) {
        bytes.addAll(chunk);
      }

      final filename = getHeaderSubParam(disposition, 'filename');
      if (filename != null) {
        final contentType =
            headers.get('content-type')?.split(';').firstOrNull?.trim();
        final data = Uint8List.fromList(bytes);
        form.add(FormDataFile.fromData(
          name,
          data,
          mimeType: contentType,
          length: data.lengthInBytes,
          path: filename,
        ));
        continue;
      }

      form.add(FormDataString(name, utf8.decode(bytes)));
    }

    return form;
  }
}

Uint8List _createHeader(String name) {
  return utf8.encode(
      'Content-Disposition: form-data; name="${Uri.encodeComponent(name)}"');
}

Stream<Uint8List> _createStringEntryStream(FormDataString entry) async* {
  yield _createHeader(entry.name);

  final lineTerminator = utf8.encode(_lineTerminatorStr);
  yield lineTerminator;
  yield lineTerminator;
  yield utf8.encode(entry.value);
  yield lineTerminator;
}

Stream<Uint8List> _createFileEntryStream(FormDataFile file) async* {
  yield _createHeader(file.name);
  yield utf8.encode('; filename="${Uri.encodeComponent(basename(file.path))}"');

  final lineTerminator = utf8.encode(_lineTerminatorStr);
  yield lineTerminator;
  yield utf8
      .encode('Content-Type: ${file.mimeType ?? 'application/octet-stream'}');
  yield lineTerminator;
  yield lineTerminator;
  yield await file.readAsBytes();
  yield lineTerminator;
}
