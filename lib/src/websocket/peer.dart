import '../core/event.dart';
import 'message.dart';
import 'ready_state.dart';

abstract interface class Peer implements Event {
  String get identifier;
  ReadyState get readyState;
  String? get protocol;
  String get extension;

  void send(Message message);
  void close([int? code, String? reason]);
}
