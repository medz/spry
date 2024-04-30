// ignore_for_file: file_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:webfetch/webfetch.dart' hide fetch;
import 'package:webfetch/webfetch.dart' as webfetch show fetch, Client;

import '../_internal/map+value_of.dart';
import 'request+locals.dart';

extension Request$Fetch on HttpRequest {
  Fetch get fetch => webfetch.fetch.use(client);
}

extension on HttpRequest {
  static const key = #spry.request.fetch.client;

  webfetch.Client get client {
    return locals.valueOf<webfetch.Client>(key, (_) {
      return locals[key] = FetchClient(requestedUri);
    });
  }
}

class FetchClient implements webfetch.Client {
  final Uri base;

  const FetchClient(this.base);

  @override
  Future<Response> send(Request request, {bool keepalive = false}) {
    return webfetch.fetch(
      URL(request.url, base),
      keepalive: keepalive,
      method: request.method,
      headers: request.headers,
      body: request.body,
    );
  }
}

class SpryFetchRequest implements Request {
  const SpryFetchRequest(this.request, this.url);

  final Request request;

  @override
  final String url;

  @override
  Future<ArrayBuffer> arrayBuffer() => request.arrayBuffer();

  @override
  Future<Blob> blob() => request.blob();

  @override
  Stream<Uint8List>? get body => request.body;

  @override
  bool get bodyUsed => request.bodyUsed;

  @override
  RequestCache get cache => request.cache;

  @override
  Request clone() => SpryFetchRequest(request.clone(), url);

  @override
  RequestCredentials get credentials => request.credentials;

  @override
  RequestDestination get destination => request.destination;

  @override
  Future<FormData> formData() => request.formData();

  @override
  Headers get headers => request.headers;

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
}
