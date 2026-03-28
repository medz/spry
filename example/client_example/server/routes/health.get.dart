import 'package:spry/spry.dart';

Response handler(Event event) =>
    .json({'status': 'ok', 'service': 'client-example'});
