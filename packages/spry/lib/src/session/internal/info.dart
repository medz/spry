import '../types.dart';

class Info {
  Info({
    required this.identifierGenerator,
    required this.identifier,
  });

  final SessionIdentifierGenerator identifierGenerator;

  String identifier;
  bool renewed = false;

  // Regenerate the session identifier.
  Future<void> regenerate() async {
    identifier = await identifierGenerator();
    renewed = true;
  }
}
