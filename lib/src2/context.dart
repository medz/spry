/// Spry request event context.
extension type SpryContext._(Map<Symbol, dynamic> _)
    implements Map<Symbol, dynamic> {
  /// Creates a new Spry context.
  factory SpryContext([Map<Symbol, dynamic>? init]) {
    return SpryContext._(init ?? {});
  }

  /// Returns matched route params.
  Map<String, String>? get params => _[#spry.event.context.params];

  /// Sets matched route params
  set params(Map<String, String>? params) {
    _[#spry.event.context.params] = params;
  }

  /// Returns trusted IP Address of client.
  String? get clientAddress => _[#spry.event.context.client_address];

  /// Sets trusted IP address of client.
  set clientAddress(String? address) {
    _[#spry.event.context.client_address] = address;
  }
}
