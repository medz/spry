// ignore_for_file: file_names

import '../locals/_locals+get_or_set.dart';
import 'event.dart';

extension EventSetHeaders on Event {
  static const kResponsibleHeaders = #spry.event.responsible.headers;

  void setHeaders(Map<String, String> headers) {
    final responsibleHeaders = locals.getOrSet<Map<String, String>>(
        kResponsibleHeaders, Map<String, String>.new);
    responsibleHeaders.addAll(headers);
  }
}
