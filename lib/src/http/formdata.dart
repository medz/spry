import 'dart:convert';
import 'dart:typed_data';

import 'package:mime/mime.dart' show MimeMultipartTransformer;
import 'package:path/path.dart' show basename;

import '_utils.dart';
import 'cross_file.dart';
import 'headers.dart';

const _lineTerminatorStr = '\r\n';

/// [FormData] entry base class.
///
/// * [FormDataString] - Creates a [String] value form-data field.
/// * [FormDataFile] - Creates a [CrossFile] value form-data field.
sealed class FormDataEntry {
  /// {@template spry.formdata.entry.constructor}
  /// Creates a new form-data entry.
  ///
  /// * [name]: The form-data field name.
  /// {@endtemplate}
  const FormDataEntry(this.name);

  /// The form-data field name.
  final String name;
}

/// [FormData] string field entry.
///
/// Example:
/// {@template spry.formdata.example.str}
/// ```dart
/// final form = FormData([
///   FormDataString('foo', 'bar'),
/// ]);
///
/// // Append a new field.
/// form.add(FormDataString('a', 'b'));
/// ```
/// {@endtemplate}
final class FormDataString extends FormDataEntry {
  /// {@macro spry.formdata.entry.constructor}
  /// * [value]: The field string value.
  ///
  /// Example:
  /// {@macro spry.formdata.example.str}
  const FormDataString(super.name, this.value);

  /// The field string value.
  final String value;
}

/// [FormData] file field entry.
///
/// Example:
/// {@template spry.formdata.example.file}
/// ```dart
/// final form = FormData([
///   FormDataFile('brand', '/images/logo/spry.web'),
/// ]);
/// ```
/// {@endtemplate}
final class FormDataFile extends FormDataEntry implements CrossFile {
  /// {@macro spry.formdata.entry.constructor}
  /// {@template spry.formdata.file.path}
  /// * [path]: The file path.
  /// {@endtemplate}
  /// {@template spry.formdata.file.params}
  /// * [mimeType]: The file mime-type.
  /// * [length]: The file length in bytes.
  /// * [lastModified]: The file last modified time.
  /// {@endtemplate}
  /// {@template spry.formdata.file.bytes}
  /// * [bytes]: The file contents of bytes.
  /// {@endtemplate}
  ///
  /// Example:
  /// {@macro spry.formdata.example.file}
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

  /// {@macro spry.formdata.entry.constructor}
  /// {@macro spry.formdata.file.bytes}
  /// {@macro spry.formdata.file.path}
  /// {@macro spry.formdata.file.params}
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

  /// {@macro spry.formdata.entry.constructor}
  /// * [file]: The form-data field value file.
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
}

/// Form-data type.
///
/// The type is form-data fields container, impl of [List<FormDataEntry>].
extension type FormData._(List<FormDataEntry> entries)
    implements List<FormDataEntry> {
  /// Creates a new [FormData].
  ///
  /// * [init]: the init fields.
  ///
  /// Only string parts example:
  /// {@macro spry.formdata.example.str}
  ///
  /// Only files example:
  /// {@macro spry.formdata.example.file}
  ///
  /// Mixed example:
  /// ```dart
  /// final form = FormData([
  ///   FormDataString('a', 'b'),
  ///   FormDataFile('b', 'demo.mp4'),
  /// ]);
  /// ```
  factory FormData([Iterable<FormDataEntry>? init]) {
    final form = FormData._([]);
    if (init != null && init.isNotEmpty) {
      for (final entry in init) {
        form.add(entry);
      }
    }

    return form;
  }

  /// Encode a [FormData] to [Stream].
  ///
  /// * [boundary]: Boundary string used to construct form data binary encoding.
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

  /// Parse a [stream] and returns [FormData].
  ///
  /// - [boundary]: The boundary string contained in the form data binary.
  /// - [stream]: Form data binary stream.
  ///
  /// > [!NOTE]
  /// >
  /// > Usually, the boundary can be obtained from the header `contents-type`.
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
