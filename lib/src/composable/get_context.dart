import '../context.dart';
import '../event.dart';
import 'get_raw_event.dart';

Context getContext(Event event) => getRawEvent(event).context;
