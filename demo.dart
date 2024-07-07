import 'dart:convert';

demo() {
  final types =
      'text/plain; charset=utf-8, application/json; charset=utf-8'.split(',');
  for (final type in types) {
    for (final param in type.split(';')) {
      final kv = param.trim().toLowerCase().split('=');
      if (kv.length == 2 && kv[0] == 'charset') {
        final encoding = Encoding.getByName(kv[1].trim());
        if (encoding != null) {
          return encoding;
        }
      }
    }
  }
}

main() {
  print(demo());
}
