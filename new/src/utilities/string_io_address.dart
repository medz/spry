extension StringIPAddress on String {
  bool isIPAddress() {
    return isIPv4Address() || isIPv6Address();
  }

  bool isIPv4Address() {
    return RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}$')
        .hasMatch(this);
  }

  bool isIPv6Address() {
    return RegExp(r'^([0-9a-fA-F]{1,4}:){7}([0-9a-fA-F]{1,4}|:)$')
        .hasMatch(this);
  }
}
