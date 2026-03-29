import 'lib/client.dart';

void main(List<String> args) async {
  final client = SpryClient();
  final user = await client.users.byId(params: .new(id: "1"));
  print(user.toJson());
}
