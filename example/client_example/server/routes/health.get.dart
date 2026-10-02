import 'package:spry/spry.dart';

Response handler(Event event) =>
    Response.json({'status': 'ok', 'service': 'client-example'});
