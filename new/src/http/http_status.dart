class HTTPStatus implements Comparable<HTTPStatus> {
  final int code;
  final String reasonPhrase;

  const HTTPStatus._(this.code, this.reasonPhrase);

  factory HTTPStatus(int code, [String? reasonPhrase]) => switch (code) {
        100 => HTTPStatus.continue_,
        101 => HTTPStatus.switchingProtocols,
        102 => HTTPStatus.processing,
        200 => HTTPStatus.ok,
        201 => HTTPStatus.created,
        202 => HTTPStatus.accepted,
        203 => HTTPStatus.nonAuthoritativeInformation,
        204 => HTTPStatus.noContent,
        205 => HTTPStatus.resetContent,
        206 => HTTPStatus.partialContent,
        207 => HTTPStatus.multiStatus,
        208 => HTTPStatus.alreadyReported,
        226 => HTTPStatus.imUsed,
        300 => HTTPStatus.multipleChoices,
        301 => HTTPStatus.movedPermanently,
        302 => HTTPStatus.found,
        303 => HTTPStatus.seeOther,
        304 => HTTPStatus.notModified,
        305 => HTTPStatus.useProxy,
        307 => HTTPStatus.temporaryRedirect,
        308 => HTTPStatus.permanentRedirect,
        400 => HTTPStatus.badRequest,
        401 => HTTPStatus.unauthorized,
        402 => HTTPStatus.paymentRequired,
        403 => HTTPStatus.forbidden,
        404 => HTTPStatus.notFound,
        405 => HTTPStatus.methodNotAllowed,
        406 => HTTPStatus.notAcceptable,
        407 => HTTPStatus.proxyAuthenticationRequired,
        408 => HTTPStatus.requestTimeout,
        409 => HTTPStatus.conflict,
        410 => HTTPStatus.gone,
        411 => HTTPStatus.lengthRequired,
        412 => HTTPStatus.preconditionFailed,
        413 => HTTPStatus.payloadTooLarge,
        414 => HTTPStatus.requestURITooLong,
        415 => HTTPStatus.unsupportedMediaType,
        416 => HTTPStatus.requestedRangeNotSatisfiable,
        417 => HTTPStatus.expectationFailed,
        418 => HTTPStatus.imATeapot,
        421 => HTTPStatus.misdirectedRequest,
        422 => HTTPStatus.unprocessableEntity,
        423 => HTTPStatus.locked,
        424 => HTTPStatus.failedDependency,
        426 => HTTPStatus.upgradeRequired,
        428 => HTTPStatus.preconditionRequired,
        429 => HTTPStatus.tooManyRequests,
        431 => HTTPStatus.requestHeaderFieldsTooLarge,
        444 => HTTPStatus.connectionClosedWithoutResponse,
        451 => HTTPStatus.unavailableForLegalReasons,
        500 => HTTPStatus.internalServerError,
        501 => HTTPStatus.notImplemented,
        502 => HTTPStatus.badGateway,
        503 => HTTPStatus.serviceUnavailable,
        504 => HTTPStatus.gatewayTimeout,
        505 => HTTPStatus.httpVersionNotSupported,
        506 => HTTPStatus.variantAlsoNegotiates,
        507 => HTTPStatus.insufficientStorage,
        508 => HTTPStatus.loopDetected,
        510 => HTTPStatus.notExtended,
        511 => HTTPStatus.networkAuthenticationRequired,
        599 => HTTPStatus.networkConnectTimeoutError,
        _ => HTTPStatus._(code, reasonPhrase ?? 'Unknown'),
      };

  //----------------------------------------------------------------
  // all the codes from http://www.iana.org/assignments/http-status-codes
  //----------------------------------------------------------------

  // 1xx
  static const HTTPStatus continue_ = HTTPStatus._(100, 'Continue');
  static const HTTPStatus switchingProtocols =
      HTTPStatus._(101, 'Switching Protocols');
  static const HTTPStatus processing = HTTPStatus._(102, 'Processing');

  // 2xx
  static const HTTPStatus ok = HTTPStatus._(200, 'OK');
  static const HTTPStatus created = HTTPStatus._(201, 'Created');
  static const HTTPStatus accepted = HTTPStatus._(202, 'Accepted');
  static const HTTPStatus nonAuthoritativeInformation =
      HTTPStatus._(203, 'Non-Authoritative Information');
  static const HTTPStatus noContent = HTTPStatus._(204, 'No Content');
  static const HTTPStatus resetContent = HTTPStatus._(205, 'Reset Content');
  static const HTTPStatus partialContent = HTTPStatus._(206, 'Partial Content');
  static const HTTPStatus multiStatus = HTTPStatus._(207, 'Multi-Status');
  static const HTTPStatus alreadyReported =
      HTTPStatus._(208, 'Already Reported');
  static const HTTPStatus imUsed = HTTPStatus._(226, 'IM Used');

  // 3xx
  static const HTTPStatus multipleChoices =
      HTTPStatus._(300, 'Multiple Choices');
  static const HTTPStatus movedPermanently =
      HTTPStatus._(301, 'Moved Permanently');
  static const HTTPStatus found = HTTPStatus._(302, 'Found');
  static const HTTPStatus seeOther = HTTPStatus._(303, 'See Other');
  static const HTTPStatus notModified = HTTPStatus._(304, 'Not Modified');
  static const HTTPStatus useProxy = HTTPStatus._(305, 'Use Proxy');
  static const HTTPStatus temporaryRedirect =
      HTTPStatus._(307, 'Temporary Redirect');
  static const HTTPStatus permanentRedirect =
      HTTPStatus._(308, 'Permanent Redirect');

  // 4xx
  static const HTTPStatus badRequest = HTTPStatus._(400, 'Bad Request');
  static const HTTPStatus unauthorized = HTTPStatus._(401, 'Unauthorized');
  static const HTTPStatus paymentRequired =
      HTTPStatus._(402, 'Payment Required');
  static const HTTPStatus forbidden = HTTPStatus._(403, 'Forbidden');
  static const HTTPStatus notFound = HTTPStatus._(404, 'Not Found');
  static const HTTPStatus methodNotAllowed =
      HTTPStatus._(405, 'Method Not Allowed');
  static const HTTPStatus notAcceptable = HTTPStatus._(406, 'Not Acceptable');
  static const HTTPStatus proxyAuthenticationRequired =
      HTTPStatus._(407, 'Proxy Authentication Required');
  static const HTTPStatus requestTimeout = HTTPStatus._(408, 'Request Timeout');
  static const HTTPStatus conflict = HTTPStatus._(409, 'Conflict');
  static const HTTPStatus gone = HTTPStatus._(410, 'Gone');
  static const HTTPStatus lengthRequired = HTTPStatus._(411, 'Length Required');
  static const HTTPStatus preconditionFailed =
      HTTPStatus._(412, 'Precondition Failed');
  static const HTTPStatus payloadTooLarge =
      HTTPStatus._(413, 'Payload Too Large');
  static const HTTPStatus requestURITooLong =
      HTTPStatus._(414, 'Request-URI Too Long');
  static const HTTPStatus unsupportedMediaType =
      HTTPStatus._(415, 'Unsupported Media Type');
  static const HTTPStatus requestedRangeNotSatisfiable =
      HTTPStatus._(416, 'Requested Range Not Satisfiable');
  static const HTTPStatus expectationFailed =
      HTTPStatus._(417, 'Expectation Failed');
  static const HTTPStatus imATeapot = HTTPStatus._(418, 'I\'m a teapot');
  static const HTTPStatus misdirectedRequest =
      HTTPStatus._(421, 'Misdirected Request');
  static const HTTPStatus unprocessableEntity =
      HTTPStatus._(422, 'Unprocessable Entity');
  static const HTTPStatus locked = HTTPStatus._(423, 'Locked');
  static const HTTPStatus failedDependency =
      HTTPStatus._(424, 'Failed Dependency');
  static const HTTPStatus upgradeRequired =
      HTTPStatus._(426, 'Upgrade Required');
  static const HTTPStatus preconditionRequired =
      HTTPStatus._(428, 'Precondition Required');
  static const HTTPStatus tooManyRequests =
      HTTPStatus._(429, 'Too Many Requests');
  static const HTTPStatus requestHeaderFieldsTooLarge =
      HTTPStatus._(431, 'Request Header Fields Too Large');
  static const HTTPStatus connectionClosedWithoutResponse =
      HTTPStatus._(444, 'Connection Closed Without Response');
  static const HTTPStatus unavailableForLegalReasons =
      HTTPStatus._(451, 'Unavailable For Legal Reasons');

  // 5xx
  static const HTTPStatus internalServerError =
      HTTPStatus._(500, 'Internal Server Error');
  static const HTTPStatus notImplemented = HTTPStatus._(501, 'Not Implemented');
  static const HTTPStatus badGateway = HTTPStatus._(502, 'Bad Gateway');
  static const HTTPStatus serviceUnavailable =
      HTTPStatus._(503, 'Service Unavailable');
  static const HTTPStatus gatewayTimeout = HTTPStatus._(504, 'Gateway Timeout');
  static const HTTPStatus httpVersionNotSupported =
      HTTPStatus._(505, 'HTTP Version Not Supported');
  static const HTTPStatus variantAlsoNegotiates =
      HTTPStatus._(506, 'Variant Also Negotiates');
  static const HTTPStatus insufficientStorage =
      HTTPStatus._(507, 'Insufficient Storage');
  static const HTTPStatus loopDetected = HTTPStatus._(508, 'Loop Detected');
  static const HTTPStatus notExtended = HTTPStatus._(510, 'Not Extended');
  static const HTTPStatus networkAuthenticationRequired =
      HTTPStatus._(511, 'Network Authentication Required');

  // Client generated status code.
  static const HTTPStatus networkConnectTimeoutError =
      HTTPStatus._(599, 'Network Connect Timeout Error');

  /// Whether responses with this status code may have a response body.
  bool hasResponseBody() {
    switch (this) {
      case HTTPStatus.continue_:
      case HTTPStatus.switchingProtocols:
      case HTTPStatus.processing:
      case HTTPStatus.noContent:
      case HTTPStatus.notModified:
      case HTTPStatus.networkConnectTimeoutError:
      case HTTPStatus(code: final code) when code >= 100 && code < 200:
        return false;
      default:
        return true;
    }
  }

  @override
  int compareTo(HTTPStatus other) => code.compareTo(other.code);

  /// Returns a string representation of this HTTP status.
  String get description => '$code $reasonPhrase';

  @override
  String toString() => description;
}

/// [int] cast [HTTPStatus].
extension HTTPStatusCast on int {
  /// Cast [int] to [HTTPStatus].
  HTTPStatus get httpStatus => HTTPStatus(this);
}
