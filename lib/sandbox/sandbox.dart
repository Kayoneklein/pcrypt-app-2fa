import 'dart:typed_data';

import 'package:pcrypt/model/attachment.dart';
import 'package:pcrypt/model/encrypted.dart';
import 'package:pcrypt/model/group.dart';
import 'package:pcrypt/model/location.dart';
import 'package:pcrypt/model/password.dart';
import 'package:pcrypt/model/pcrypt_key.dart';
import 'package:pcrypt/model/team.dart';
import 'package:pcrypt/model/user.dart';
import 'package:pcrypt/web/local_db_service.dart';
import 'package:pcrypt/web/web.dart';

class ReadOnlySandbox {
  final _db = LocalDBService.db;

  Future addUser() async {
    final user = User(
      id: 2,
      name: 'Joshua Aghanti',
      department: 'Dev',
      avatar: Uint8List(0),
      isEmailVerified: true,
      isPremium: false,
      isPremiumTrial: false,
      email: 'kayoneklein@gmail.com',
    );
    // _db.insertData(user: user);
  }

  Future addPassword() async {
    await _db.deleteDBTaleData(LocalDBTable.password);
    final password = Password(
      groupIds: [],
      name: 'Test password name',
      user: 'user1234',
      password: 'password',
      url: 'http://google.com',
      note: 'This is a test note',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      locations: [
        const Location(
          title: 'Delta State',
          latitude: 0.001,
          longitude: 5.236,
          accuracy: 3,
        ),
      ],
      files: [
        Attachment('12', 'Attachment 1', 'pdf'),
        Attachment('13', 'Attachment 2', 'jpg'),
      ],
      oldFiles: [
        OldAttachment('old12', {'name': 'old'}),
        OldAttachment('old22', {'name': 'old again'}),
      ],
      shares: {},
      shareChanges: {},
      shareTeamIds: [],
      id: 'password1234',
    );

    // _db.createPassword(password);
  }

  Future addGroup() async {
    final grp = Group(
      id: '1234',
      name: 'group name',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final group = await _db.addGroup(grp);
    print('group');
    print(group);
  }

  Future addTeam() async {
    const team = Team(
      id: 123,
      isAdmin: false,
      isTeamCreator: true,
      isApproved: true,
      username: 'username',
      department: 'Dev',
      name: 'dev team',
      contact: 'contact',
      email: 'email@email.com',
      options: {'hey': 'hey'},
    );
    final tm = await _db.addTeam(team);
    print('tm');
    print(tm);
  }

  Future addTeamMember() async {
    const enc = Encrypted(
      info: 'info',
      type: 'type',
      version: 1,
      encoding: 'encoding',
      compression: 'compression',
      algorithm: 'algorithm',
      iv: 'iv',
      data: 'data',
    );
    const pcKey = PCryptKey(
      info: 'info',
      algorithm: 'algorithm',
      version: 1,
      type: 'type',
      encoding: 'encoding',
      ecdh: EllipticCurve(curve: 'curve', data: 'data'),
      ecdsa: EllipticCurve(curve: 'curve', data: 'data'),
    );
    final member = TeamMember(
      userId: 12345,
      name: 'Josh Aghanti',
      department: 'Dev',
      email: 'email@email.com',
      isAdmin: false,
      isTeamCreator: true,
      isApproved: true,
      userOptions: {},
      userHidePassword: true,
      userNoShare: true,
      teamId: 123,
      teamName: 'teamName',
      teamHidePassword: true,
      teamOnlyAdminShare: true,
      teamKeysFromId: {},
      teamKeysData: enc,
      publicKey: pcKey,
      createdAt: DateTime.now(),
    );
    final mem = await _db.addTeamMembers(member);
    print('mem');
    print(mem);
  }

  Future addEncrypted() async {
    const encrypted = Encrypted(
      info: 'info',
      type: 'type',
      version: 1,
      encoding: 'encoding',
      compression: 'compression',
      algorithm: 'algorithm',
      iv: 'iv',
      data: 'data',
    );
    // final enc = await _db.addEncrypted(encrypted);
    print('enc');
    // print(enc);
  }

  Future addPcryptKey() async {
    const pcKey = PCryptKey(
      info: 'info',
      algorithm: 'algorithm',
      version: 1,
      type: 'type',
      encoding: 'encoding',
      ecdh: EllipticCurve(curve: 'curve', data: 'data'),
      ecdsa: EllipticCurve(curve: 'curve', data: 'data'),
    );
    // final key = await _db.addPcryptKey(pcKey);
    print('key');
    // print(key);
  }

  Future getUser() async {
    final user = await _db.getData(tbl: LocalDBTable.user);
    print('user');
    print(user);
  }

  Future getGroup() async {
    final groups = await _db.getData(tbl: LocalDBTable.group);
    print('groups');
    print(groups);
    print(groups.length);
  }

  Future getTeam() async {
    final teams = await _db.getData(tbl: LocalDBTable.team);
    print('teams');
    print(teams);
    print(teams.length);
  }

  Future addTeamShare() async {
    const share = TeamShare(
      type: TeamShareType.team,
      userId: 3050,
      email: 'email@email.com',
      read: 1,
      hash: 'hash',
      data: Encrypted(
        info: 'info',
        type: 'type',
        version: 1,
        encoding: 'encoding',
        compression: 'compression',
        algorithm: 'algorithm',
        iv: 'iv',
        data: 'data',
      ),
      keyId: 12,
      teamId: 1345,
    );
    final teams = await _db.addTeamShare(share);
    print('teams');
    print(teams);
  }

  Future getTeamShare() async {
    final shares = await _db.getData(tbl: LocalDBTable.teamShare);
    print('shares');
    print(shares);
    print(shares.length);
  }

  Future getremoteConfig() async {
    final teams = await _db.getData(tbl: LocalDBTable.remoteConfig);
    print('teams');
    print(teams);
  }

  Future getTeamMembers() async {
    final teams = await _db.getData(tbl: LocalDBTable.teamMembers);
    print('teams');
    print(teams);
    print(teams.length);
  }

  Future getEnc() async {
    final enc = await _db.getEncrypted(DataName.groups);
    print('enc');
    print(enc);
  }

  Future getFavicon() async {
    final enc = await _db.getPasswordFavicons();
    print('enc');
    print(enc);
    print(enc.length);
  }

  Future getPassword() async {
    // _db.closeDb();
    // _db.addTable();
    // _db.viewTables();

    final pass = await _db.getData(tbl: LocalDBTable.password);
    print('pass');
    print(pass);
    print(pass.length);
  }
}
