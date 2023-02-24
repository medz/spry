part of '../multer.dart';

class _MulterImpl extends Multer {
  const _MulterImpl({this.encoding}) : super._internal();

  @override
  final Encoding? encoding;

  @override
  Future<Multipart> createMultipart(String boundary, Request request) async {
    final fields = <String, List<String>>{};
    final files = <String, List<File>>{};
    final transformer = MimeMultipartTransformer(boundary);
    final encoding = _resolveEncoding(request.context);

    await for (final part in transformer.bind(request.stream())) {
      final headers =
          part.headers.map((key, value) => MapEntry(key.toLowerCase(), value));
      final contentDisposition = headers['content-disposition'];

      if (contentDisposition == null) {
        continue;
      }

      final headerParameters = HeaderValue.parse(contentDisposition);
      final name = headerParameters.parameters['name']!;
      final filename = headerParameters.parameters['filename'];

      if (filename != null) {
        final type = part.headers['content-type'];
        final contentType =
            type == null ? ContentType.binary : ContentType.parse(type);

        if (files[name] == null) {
          files[name] = [];
        }

        files[name]!.add(FileImpl(
          part,
          contentType: contentType,
          filename: filename,
        ));

        print(contentType);
        continue;
      }

      if (fields[name] == null) {
        fields[name] = [];
      }

      fields[name]!.add(await encoding.decodeStream(part));
      print(fields[name]);
    }

    return Multipart(fields, files);
  }

  /// Find the [Encoding] to use for the [Context].
  Encoding _resolveEncoding(Context context) {
    if (encoding != null) {
      return encoding!;
    }

    final app = context.get(SPRY_APP) as Spry;

    return app.encoding;
  }
}
