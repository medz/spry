import 'headers.dart';

/// Spry Request
///
/// The [Request] interface of the Fetch API represents a resource request.
///
/// @see [Request](https://developer.mozilla.org/en-US/docs/Web/API/Request)
abstract class Request {
  /// Return a read-only [Stream] of the body bytes.
  Stream<List<int>> get body;

  /// Contains the cache mode of the request.
  ///
  /// e.g: `no-cache`, `reload`, `no-store`, `force-cache`, `only-if-cached`
  String get cache;

  /// Contains the credentials of the request
  ///
  /// e.g: `omit`, `same-origin`, `include`
  ///
  /// The default is `same-origin`.
  String get credentials;

  /// Returns a string describing the request's destination.
  ///
  /// This is a string indicating the type of content being requested.
  String get destination;

  /// Contains the associated [Headers] object of the request.
  Headers get headers;

  /// Contains the [subresource integrity][https://developer.mozilla.org/en-US/docs/Web/Security/Subresource_Integrity] value of the request
  ///
  /// e.g: `sha256-BpfBw7ivV8q2jLiT13fxDYAe2tJllusRSZ273h2nFSE=`
  String get integrity;

  /// Contains the request's method (GET, POST, etc.)
  String get method;

  /// Contains the mode for how redirects are handled.
  ///
  /// It may be one of `follow`, `error`, or `manual`.
  String get redirect;

  /// Contains the referrer of the request.
  ///
  /// e.g: `client`
  String get referrer;

  /// Contains the referrer policy of the request
  ///
  /// e.g: `no-referrer`, `no-referrer-when-downgrade`, `origin`, `origin-when-cross-origin`, `unsafe-url`
  String get referrerPolicy;

  /// Contains the URL of the request
  Uri get url;
}
