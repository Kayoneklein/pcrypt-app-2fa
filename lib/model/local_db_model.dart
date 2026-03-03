import 'package:pcrypt/model/message.dart';
import 'package:pcrypt/model/password.dart';
import 'package:pcrypt/model/user.dart' show User;

class LocalDBModel {
  const LocalDBModel({
    this.user,
    this.passwords = const [],
    //  this.messages,
  });

  final User? user;
  final List<Password> passwords;
// final List<Message> messages;
}
