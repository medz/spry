import 'package:spry/spry.dart';

import 'multer.dart';
import 'multipart.dart';

/// Multer extension on [Request].
extension SpryMulterExtension on Request {
  /// Find or create a [Multipart] instance on the [Request].
  Future<Multipart> multipart() async {
    // If the [Request] already contains a [Multipart] instance, return it.
    if (context.contains(Multipart)) {
      return context.get(Multipart) as Multipart;
    }

    final contenType = headers.contentType;
    final boundary = contenType?.parameters['boundary'];

    // If content type is not multipart/form-data and boundary is not present,
    // throw an exception.
    if (contenType?.mimeType.toLowerCase() != 'multipart/form-data' ||
        boundary == null) {
      throw HttpException.badGateway('Content type is not multipart/form-data');
    }

    final multer = Multer.of(context);
    final multipart = await multer.createMultipart(boundary, this);
    context.set(Multipart, multipart);

    return multipart;
  }
}
