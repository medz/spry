/// Options controlling compression in a [WebSocket].
///
/// A [CompressionOptions] instance can be passed to [WebSocket.connect], or
/// used in other similar places where [WebSocket] compression is configured.
///
/// In most cases the default [compressionDefault] is sufficient, but in some
/// situations, it might be desirable to use different compression parameters,
/// for example to preserve memory on small devices.
class CompressionOptions {
  const CompressionOptions(
      {this.clientNoContextTakeover = false,
      this.serverNoContextTakeover = false,
      this.clientMaxWindowBits,
      this.serverMaxWindowBits,
      this.enabled = true});

  /// Whether the client will reuse its compression instances.
  final bool clientNoContextTakeover;

  /// Whether the server will reuse its compression instances.
  final bool serverNoContextTakeover;

  /// The maximal window size bit count requested by the client.
  ///
  /// The windows size for the compression is always a power of two, so the
  /// number of bits precisely determines the window size.
  ///
  /// If set to `null`, the client has no preference, and the compression can
  /// use up to its default maximum window size of 15 bits depending on the
  /// server's preference.
  final int? clientMaxWindowBits;

  /// The maximal window size bit count requested by the server.
  ///
  /// The windows size for the compression is always a power of two, so the
  /// number of bits precisely determines the window size.
  ///
  /// If set to `null`, the server has no preference, and the compression can
  /// use up to its default maximum window size of 15 bits depending on the
  /// client's preference.
  final int? serverMaxWindowBits;

  /// Whether WebSocket compression is enabled.
  ///
  /// If not enabled, the remaining fields have no effect, and the
  /// [compressionOff] instance can, and should, be reused instead of creating a
  /// new instance with compression disabled.
  final bool enabled;
}
