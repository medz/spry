import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' show basename;
import 'package:webfetch/webfetch.dart' as webfetch;

// ignore: implementation_imports
import 'package:webfetch/src/_internal/generate_boundary.dart'
    show generateBoundary;

import '../application+encoding.dart';
import '../request/request+application.dart';
import '../request/request+json.dart';

abstract interface class Responsible {
  /// Responds to the [request].
  Future<void> respond(HttpRequest request);

  /// Creates a [Responsible] from [object?].
  ///
  /// ```dart
  /// final respoinsible = Responsible.create(object);
  /// ```
  ///
  /// ## Supported types
  /// - [Responsible]
  /// - [Map]
  /// - [Iterable]
  /// - [Stream<List<int>>]
  /// - [webfetch.FormData]
  /// - [webfetch.Response]
  /// - [File]
  /// - [null]
  /// - Dart scalar types, Eg: `String`, `int`, `double`, `bool`...
  factory Responsible.create(Object? object) {
    return switch (object) {
      webfetch.Blob blob => _StreamResponsible(blob.stream()),
      webfetch.FormData formData => _FormDataResponsible(formData),
      webfetch.Response response => _WebfetchResponseResponsible(response),
      Responsible responsible => responsible,
      HttpClientResponse response => _HttpClientResponsesible(response),
      HttpResponse _ => const _NullResponsible(),
      Map map => _JsonResponsible(map),
      Iterable iterable => _JsonResponsible(iterable.toList(growable: false)),
      Stream<List<int>> stream => _StreamResponsible(stream),
      TypedData typedData => _TypedDataResponsible(typedData),
      File file => _FileResponsible(file),
      null => const _NullResponsible(),
      _ => _NominalResponsible(object),
    };
  }
}

class _TypedDataResponsible implements Responsible {
  final TypedData typedData;

  const _TypedDataResponsible(this.typedData);

  @override
  Future<void> respond(HttpRequest request) async {
    final response = request.response;
    final encoding = request.application.encoding;
    final bytes = typedData.buffer.asUint8List();

    response.headers.contentType = response.headers.contentType =
        ContentType('application', 'octet-stream', charset: encoding.name);
    response.add(bytes);
  }
}

class _HttpClientResponsesible implements Responsible {
  final HttpClientResponse response;

  const _HttpClientResponsesible(this.response);

  @override
  Future<void> respond(HttpRequest request) async {
    final innerResponse = request.response;

    innerResponse.statusCode = response.statusCode;
    innerResponse.contentLength = response.contentLength;
    innerResponse.cookies.addAll(response.cookies);
    response.headers.forEach((name, values) {
      for (final value in values) {
        innerResponse.headers.add(name, value);
      }
    });

    await for (final chunk in response) {
      innerResponse.add(chunk);
    }
  }
}

class _NullResponsible implements Responsible {
  const _NullResponsible();

  @override
  Future<void> respond(HttpRequest request) async {}
}

class _NominalResponsible implements Responsible {
  final Object? object;

  const _NominalResponsible(this.object);

  @override
  Future<void> respond(HttpRequest request) async {
    request.response.write(object);
  }
}

class _FileResponsible implements Responsible {
  final File file;

  const _FileResponsible(this.file);

  @override
  Future<void> respond(HttpRequest request) async {
    final response = request.response;

    // Set download headers
    response.headers.contentType = ContentType.binary;
    response.headers.add(
      'Content-Disposition',
      'attachment; filename="${Uri.encodeComponent(basename(file.path))}"',
    );

    await response.addStream(file.openRead());
  }
}

class _WebfetchResponseResponsible implements Responsible {
  final webfetch.Response response;

  const _WebfetchResponseResponsible(this.response);

  @override
  Future<void> respond(HttpRequest request) async {
    for (final (name, value) in response.headers.entries()) {
      request.response.headers.add(name, value);
    }
    for (final cookie in response.headers.getSetCookie()) {
      request.response.cookies.add(Cookie.fromSetCookieValue(cookie));
    }

    final stream = response.body;
    if (stream != null) {
      await request.response.addStream(stream);
    }
  }
}

class _FormDataResponsible implements Responsible {
  final webfetch.FormData formData;

  const _FormDataResponsible(this.formData);

  @override
  Future<void> respond(HttpRequest request) async {
    final response = request.response;
    final boundary = this.boundary;

    final stream = webfetch.FormData.encode(formData, boundary);
    response.headers.contentType = ContentType(
      'multipart',
      'form-data',
      parameters: {
        'boundary': boundary,
      },
      charset: request.application.encoding.name,
    );

    await response.addStream(stream);
  }

  String get boundary {
    final value = generateBoundary();
    return '--spry--${value.substring(value.length - 60)}';
  }
}

class _StreamResponsible implements Responsible {
  final Stream<List<int>> stream;

  const _StreamResponsible(this.stream);

  @override
  Future<void> respond(HttpRequest request) async {
    await request.response.addStream(stream);
  }
}

class _JsonResponsible implements Responsible {
  final Object object;

  const _JsonResponsible(this.object);

  @override
  Future<void> respond(HttpRequest request) async {
    final response = request.response;
    final encoding = request.application.encoding;
    final value = request.jsonCodec.encode(object);
    final bytes = encoding.encode(value);

    response.headers.contentType = response.headers.contentType =
        ContentType('application', 'json', charset: encoding.name);
    response.add(bytes);
  }
}
