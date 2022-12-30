// ignore_for_file: constant_identifier_names

/// Spry core constants.
library spry.constants;

/// Origin http request in [Context] store under this key.
///
/// See [Context.get] and [Context.set].
const Symbol SPRY_HTTP_ORIGIN_REQUEST = Symbol('#spry.http-origin-request');

/// Spry http request in [Context] store under this key.
const Symbol SPRY_HTTP_REQUEST = Symbol('#spry.http-request');

/// Spry http response in [Context] store under this key.
const Symbol SPRY_HTTP_RESPONSE = Symbol('#spry.http-response');
