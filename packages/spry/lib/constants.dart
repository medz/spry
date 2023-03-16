// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// Spry core constants.
library spry.constants;

import 'dart:io';

import 'spry.dart';

/// Origin http request in [Context] store under this key.
///
/// See [Context.get] and [Context.set].
@Deprecated(
  'Use HttpRequest instead, which is exported by dart:io \n'
  'Will be removed in 2.0.0.',
)
const Type SPRY_HTTP_ORIGIN_REQUEST = HttpRequest;

/// Spry http request in [Context] store under this key.
@Deprecated(
  'Use Request instead, which is exported by spry \n'
  'Will be removed in 2.0.0.',
)
const Type SPRY_HTTP_REQUEST = Request;

/// Spry http response in [Context] store under this key.
@Deprecated(
  'Use Response instead, which is exported by spry \n'
  'Will be removed in 2.0.0.',
)
const Type SPRY_HTTP_RESPONSE = Response;

/// Spry application in [Context] store under this key.
@Deprecated(
  'Use Symbol instead, which is exported by spry \n'
  'Will be removed in 2.0.0.',
)
const Type SPRY_APP = Spry;
