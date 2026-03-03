import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pcrypt/model/password.dart';

void main() {
  test('Password parsed and encoded', () {
    const original = '{"gid":["2","MZbOUeWh5RQtcMeFgF2Lt5"],"name":"норт33f","user":"ert","pass":"erte","url":"http://google.com","note":"notes","cre":1583180707294,"upd":1592485340301,"pos":[{"text":"400, Capistrano Avenue, San Francisco, San Francisco County, California, United States","lat":"37.7255733","long":"-122.43922","acc":"20"}],"files":[{"fileid":"MdUrRkSUlZOdBqHJtr8xLE","name":"imaged5b409f4200470dddfbed52ab62334e2-V.jpg","filetype":"image/jpeg"}],"shares":{"506":[300]},"sharechanges":{"506":true},"shareteams":[]}';
    final decoded = Password.fromJson(jsonDecode(original));
    final encoded = jsonEncode(decoded.toJson());
    expect(original, encoded);
  });
}