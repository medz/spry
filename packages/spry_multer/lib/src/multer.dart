import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:spry/constants.dart';
import 'package:spry/spry.dart';

import '_internal/file_impl.dart';
import 'file.dart';
import 'multipart.dart';

part '_internal/multer_impl.dart';

/// Spry framework [Multer] middleware.
///
/// The middleware parses a multipart/form-data request and makes the parsed
/// data available on the [Request] object.
abstract class Multer {
  /// Creates a new [Multer] middleware.
  const factory Multer({Encoding? encoding}) = _MulterImpl;
  const Multer._internal();

  /// The `multipart/form-data` [Encoding] used to decode the request body.
  Encoding? get encoding;

  /// Handles the request.
  FutureOr<void> call(Context context, Next next) {
    // Register the [Multer] instance on the [Context].
    context.set(Multer, this);

    return next();
  }

  /// Find or create a [Multer] instance on the [Context].
  static Multer of(Context context) {
    if (context.contains(Multer)) {
      return context.get(Multer) as Multer;
    }

    final multer = Multer();
    context.set(Multer, multer);

    return multer;
  }

  /// Create a [Stream] of [List] of [int]s into a [Multipart] object.
  Future<Multipart> createMultipart(String boundary, Request request);
}
