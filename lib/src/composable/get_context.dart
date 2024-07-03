import '../context.dart';
import '../event.dart';

Context getContext(Event event) => event.raw.context;
