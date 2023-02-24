import 'package:spry/spry.dart';
import 'package:spry_multer/spry_multer.dart';

final spry = Spry();

handler(Context context) async {
  final request = context.request;
  final response = context.response;
  final multipart = await request.multipart();

  final sb = StringBuffer();
  sb.writeln('Fields:');
  multipart.fields.forEach((key, value) {
    sb.writeln('  $key: $value');
  });

  sb.writeln('Files:');
  multipart.files.forEach((key, field) {
    sb.writeln('  $key: ${field.map((e) => e.filename)}');
  });

  response.text(sb.toString());
}

void main() async {
  final server = await spry.listen(handler, port: 3000);
  print('Listening on http://${server.address.host}:${server.port}');
}
