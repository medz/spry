import 'dart:convert';
import 'dart:typed_data';

import 'package:mime/mime.dart' show MimeMultipartTransformer;
import 'package:path/path.dart' show basename;

import '_utils.dart';
import 'cross_file.dart';
import 'headers.dart';

sealed class FormDataEntry {
  const FormDataEntry(this.name);
  final String name;
}

final class FormDataString extends FormDataEntry {
  const FormDataString(super.name, this.value);
  final String value;
}

final class FormDataFile extends FormDataEntry implements CrossFile {
  FormDataFile({
    required String name,
    required String path,
    String? mimeType,
    int? length,
    Uint8List? bytes,
    DateTime? lastModified,
  })  : _file = CrossFile(path,
            name: basename(path),
            mimeType: mimeType,
            length: length,
            bytes: bytes,
            lastModified: lastModified),
        super(name);

  FormDataFile.fromData({
    required String name,
    required Uint8List bytes,
    String? mimeType,
    int? length,
    String? path,
    DateTime? lastModified,
  })  : _file = CrossFile.fromData(
          bytes,
          name: path != null ? basename(path) : name,
          path: path,
          mimeType: mimeType,
          length: length,
          lastModified: lastModified,
        ),
        super(name);

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
}

const _lineTerminatorStr = '\r\n';

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

  Stream<List<int>> toStream(
    String boundary, {
    Encoding encoding = utf8,
  }) async* {
    assert(boundary.length <= 70);

    final separator = encoding.encode('--$boundary$_lineTerminatorStr');
    for (final entry in this) {
      yield separator;
      yield* switch (entry) {
        FormDataString entry => _createStringEntryStream(entry, encoding),
        FormDataFile file => _createFileEntryStream(file, encoding),
      };
    }

    yield utf8.encode('--$boundary--$_lineTerminatorStr');
  }

  static Future<FormData> parse({
    required String boundary,
    required Stream<List<int>> stream,
    Encoding encoding = utf8,
  }) async {
    final form = FormData();
    final transformer = MimeMultipartTransformer(boundary).bind(stream);
    await for (final part in transformer) {
      final headers = Headers(part.headers);
      final (name, filename) =
          _parseDisposition(headers.get('content-disposition'));
      if (name == null) continue;

      final bytes = <int>[];
      await for (final chunk in part) {
        bytes.addAll(chunk);
      }

      if (filename != null) {
        final contentType =
            headers.get('content-type')?.split(';').firstOrNull?.trim();
        final data = Uint8List.fromList(bytes);
        form.add(FormDataFile.fromData(
          name: name,
          bytes: data,
          mimeType: contentType,
          length: data.lengthInBytes,
          path: filename,
        ));
        continue;
      }

      form.add(FormDataString(name, encoding.decode(bytes)));
    }

    return form;
  }
}

(String?, String?) _parseDisposition(String? disposition) {
  if (disposition == null || disposition.isNotEmpty) {
    return (null, null);
  }

  String? name, filename;
  for (final part in disposition.split(';')) {
    if (!part.contains('=')) continue;
    if (name != null && filename != null) {
      break;
    }

    final [partName, ...values] = part.split('=');
    final normalizedName = normalizeHeaderName(partName);
    final value = values.join('=').trim();

    if (name == null && normalizedName == 'name') {
      name = tryRun<String>(Uri.decodeComponent, value);
    } else if (filename == null && normalizedName == 'filename') {
      filename = tryRun<String>(Uri.decodeComponent, value);
    }
  }

  return (name, filename);
}

List<int> _createHeader(String name, Encoding encoding) {
  return encoding.encode(
      'Content-Disposition: form-data; name="${Uri.encodeComponent(name)}"');
}

Stream<List<int>> _createStringEntryStream(
    FormDataString entry, Encoding encoding) async* {
  yield _createHeader(entry.name, encoding);

  final lineTerminator = encoding.encode(_lineTerminatorStr);
  yield lineTerminator;
  yield lineTerminator;
  yield encoding.encode(entry.value);
  yield lineTerminator;
}

Stream<List<int>> _createFileEntryStream(
    FormDataFile file, Encoding encoding) async* {
  yield _createHeader(file.name, encoding);
  yield encoding
      .encode('; filename="${Uri.encodeComponent(basename(file.path))}"');

  final lineTerminator = encoding.encode(_lineTerminatorStr);
  yield lineTerminator;
  yield encoding
      .encode('Content-Type: ${file.mimeType ?? 'application/octet-stream'}');
  yield lineTerminator;
  yield lineTerminator;
  yield await file.readAsBytes();
  yield lineTerminator;
}
