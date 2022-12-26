import 'package:prexp/prexp.dart';

void main(List<String> args) {
  print(Prexp.fromString('/hello/:name/:_spry_router_mount_123456789*')
      .hasMatch('/hello/world/1/2/3'));
}
