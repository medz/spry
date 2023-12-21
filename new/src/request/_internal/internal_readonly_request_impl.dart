import 'dart:io';
import 'dart:typed_data';

import 'package:webfetch/webfetch.dart';

import '../../utilities/storage.dart';

class InternalReadonlyRequestImpl implements Request {
  factory InternalReadonlyRequestImpl(HttpRequest httpRequest) {
    final headers = Headers();
    httpRequest.headers.forEach((name, values) {
      for (final value in values) {
        headers.append(name, value);
      }
    });
    headers.set('content-length', httpRequest.contentLength.toString());

    final request = Request(
      httpRequest.requestedUri.toString(),
      body: httpRequest,
      cache: headers.get('cache-control')?.contains('no-cache') ?? false
          ? RequestCache.noStore
          : RequestCache.default_,
      method: httpRequest.method,
      headers: headers,
    );

    return InternalReadonlyRequestImpl._(request);
  }

  InternalReadonlyRequestImpl._(this.request);

  final Storage storage = Storage();

  final Request request;

  @override
  final Headers headers = Headers();

  @override
  Future<ArrayBuffer> arrayBuffer() => request.arrayBuffer();

  @override
  Future<Blob> blob() => request.blob();

  @override
  Stream<Uint8List> get body => request.body;

  @override
  bool get bodyUsed => request.bodyUsed;

  @override
  RequestCache get cache => request.cache;

  @override
  Request clone() {
    return InternalReadonlyRequestImpl._(request.clone());
  }

  @override
  RequestCredentials get credentials => request.credentials;

  @override
  RequestDestination get destination {
    final dest = headers.get('sec-fetch-dest')?.toLowerCase();
    if (dest == null) return RequestDestination.document;

    return RequestDestination.values.firstWhere(
      (e) => e.value.toLowerCase() == dest,
      orElse: () => RequestDestination.document,
    );
  }

  @override
  Future<FormData> formData() => request.formData();

  @override
  String get integrity => request.integrity;

  @override
  Future<Object> json() => request.json();

  @override
  String get method => request.method;

  @override
  RequestMode get mode => request.mode;

  @override
  RequestRedirect get redirect => request.redirect;

  @override
  String get referrer => request.referrer;

  @override
  ReferrerPolicy get referrerPolicy => request.referrerPolicy;

  @override
  Future<String> text() => request.text();

  @override
  String get url => request.url;
}
