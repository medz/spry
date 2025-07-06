import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:oxy/oxy.dart';

import '../platform.dart';

class DartNative implements Platform {
  DartNative({
    SecurityContext? securityContext,
    this.backlog = 0,
    this.shared = false,
    this.v6Only = false,
    this.requestClientCertificate = false,
  }) : _securityContext = securityContext;

  SecurityContext? _securityContext;

  HttpServer? _server;
  Future<HttpServer>? _serverFuture;

  final int backlog;
  final bool shared;
  final bool v6Only;
  final bool requestClientCertificate;

  SecurityContext? get securityContext => _securityContext;

  HttpServer get server {
    if (_server != null) return _server!;
    throw StateError('Server not initialized');
  }

  @override
  String? get url => throw UnimplementedError();

  @override
  void serve({
    required Future<Response> Function(Request request) fetch,
    String? hostname,
    int? port,
    required bool reusePort,
    TtlOptions? ttl,
  }) {
    if (_server != null || _serverFuture != null) {
      return;
    }

    final isSecure = ttl.isProvided || securityContext != null;
    if (isSecure) {
      final securityContext = _securityContext ??= SecurityContext();
      if (ttl.isProvided) {
        if (File(ttl!.cert!).existsSync()) {
          securityContext.useCertificateChain(
            ttl.cert!,
            password: ttl.passphrase,
          );
        } else {
          securityContext.useCertificateChainBytes(
            utf8.encode(ttl.cert!),
            password: ttl.passphrase,
          );
        }

        if (File(ttl.key!).existsSync()) {
          securityContext.usePrivateKey(ttl.key!, password: ttl.passphrase);
        } else {
          securityContext.usePrivateKeyBytes(
            utf8.encode(ttl.key!),
            password: ttl.passphrase,
          );
        }
      }
    }

    _serverFuture = isSecure
        ? HttpServer.bindSecure(
            hostname ?? InternetAddress.anyIPv4,
            port ?? 0,
            securityContext!,
            requestClientCertificate: requestClientCertificate,
            backlog: backlog,
            v6Only: v6Only,
            shared: shared,
          )
        : HttpServer.bind(
            hostname ?? InternetAddress.anyIPv4,
            port ?? 0,
            backlog: backlog,
            v6Only: v6Only,
            shared: shared,
          );
  }

  @override
  FutureOr<void> ready() {
    // TODO: implement ready
    throw UnimplementedError();
  }

  @override
  Future<void> close([bool force = false]) {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  String? requestIP(Request request) {
    // TODO: implement requestIP
    throw UnimplementedError();
  }

  @override
  void waitUntil<E>(FutureOr<E> future) {
    // TODO: implement waitUntil
  }
}

extension on TtlOptions? {
  bool get isProvided {
    return this?.cert != null && this?.key != null;
  }
}
