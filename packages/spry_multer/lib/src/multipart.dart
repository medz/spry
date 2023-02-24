import 'file.dart';

class Multipart {
  final Map<String, Iterable<String>> fields;
  final Map<String, Iterable<File>> files;

  const Multipart(this.fields, this.files);
}
