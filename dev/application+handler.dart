// ignore_for_file: file_names

import 'dart:io';

import '_internal/request.dart';
import 'application.dart';
import 'request/request+clone.dart';

extension Application$Handler on Application {
  /// Handler for incoming requests.
  Future<void> handler(HttpRequest request) async {
    final spryRequest = SpryRequest.from(application: this, request: request);

    final a1 = spryRequest.clone();

    print(await spryRequest.toList());
    print(await a1.toList());

    spryRequest.response
      ..write('Hello, world!')
      ..close();
  }
}
