import 'dart:convert';
import 'dart:math';

/// Generate a unique identifier.
Future<String> generateIdentifier() async {
  final Random random = Random.secure();
  final bytes = List<int>.generate(128, (index) => random.nextInt(255));

  return base64Url.encode(bytes);
}
