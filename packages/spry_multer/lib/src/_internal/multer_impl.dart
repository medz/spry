part of '../multer.dart';

class _MulterImpl extends Multer {
  const _MulterImpl() : super._internal();

  @override
  Future<Multipart> createMultipart(String boundary, Request request) async {
    final fields = <String, List<String>>{};
    final files = <String, List<File>>{};
    final transformer = MimeMultipartTransformer(boundary);
    final encoding = request.context.app.encoding;

    await for (final part in transformer.bind(request.stream())) {
      final headers =
          part.headers.map((key, value) => MapEntry(key.toLowerCase(), value));

      // If the part not contains content-disposition header, skip it.
      if (!headers.containsKey('content-disposition')) {
        continue;
      }

      // Parse the content-disposition headers
      final contentDisposition =
          HeaderValue.parse(headers['content-disposition']!);

      // If the content-disposition not contains name parameter, throw an exception.
      if (!contentDisposition.parameters.containsKey('name')) {
        throw FormatException(
          'Content-Disposition header must contain a "name" parameter.',
        );
      }

      // Read the name parameter.
      final name = contentDisposition.parameters['name']!;

      // If the content-disposition contains filename parameter, it is a file.
      if (contentDisposition.parameters.containsKey('filename')) {
        if (!files.containsKey(name)) {
          files[name] = [];
        }

        files[name]!.add(FileImpl(
          part,
          contentType: headers.containsKey('content-type')
              ? ContentType.parse(headers['content-type']!)
              : ContentType.binary,
          filename: contentDisposition.parameters['filename']!,
        ));
        continue;
      }

      if (!fields.containsKey(name)) {
        fields[name] = [];
      }

      fields[name]!.add(await encoding.decodeStream(part));
    }

    return Multipart(fields, files);
  }
}
