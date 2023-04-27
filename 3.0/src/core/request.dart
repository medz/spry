part of spry.core;

/// Spry request.
class Request implements contracts.Request {
  /// `dart:io` original request.
  final HttpRequest _request;

  @override
  Stream<List<int>> get body => _request;

  @override
  String get cache => headers.get('cache-control') ?? 'default';

  @override
  String get credentials {
    final auth = headers.get('authorization');

    if (auth == null) {
      return 'omit';
    }

    final parts = auth.split(' ');

    if (parts.length != 2) {
      return 'omit';
    }

    if (parts[0].toLowerCase() != 'basic') {
      return 'omit';
    }

    final decoded = String.fromCharCodes(base64.decode(parts[1]));
    final credentials = decoded.split(':');

    if (credentials.length != 2) {
      return 'omit';
    }

    return 'include';
  }

  @override
  // TODO: implement destination
  String get destination {
    final url = this.url.toString();

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return 'document';
    }

    return 'other';
  }

  @override
  // TODO: implement headers
  contracts.Headers get headers => throw UnimplementedError();

  @override
  // TODO: implement integrity
  String get integrity => throw UnimplementedError();

  @override
  // TODO: implement method
  String get method => throw UnimplementedError();

  @override
  // TODO: implement redirect
  String get redirect => throw UnimplementedError();

  @override
  // TODO: implement referrer
  String get referrer => throw UnimplementedError();

  @override
  // TODO: implement referrerPolicy
  String get referrerPolicy => throw UnimplementedError();

  @override
  // TODO: implement url
  Uri get url => throw UnimplementedError();
}
