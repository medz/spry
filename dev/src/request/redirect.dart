/// Specifies the type of redirect that the client should receive
enum Redirect {
  /// 301 Moved Permanently
  movedPermanently(301),

  /// 302 Found
  found(302),

  /// 303 See Other
  seeOther(303),

  /// 307 Temporary Redirect
  temporaryRedirect(307),

  /// 308 Permanent Redirect
  permanentRedirect(308);

  /// Returns the status code for this redirect
  final int status;

  const Redirect(this.status);
}
