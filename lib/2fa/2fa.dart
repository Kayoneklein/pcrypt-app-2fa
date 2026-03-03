part of 'index.dart';

Future<void> _sandbox() async {
  const String publicKey = 'random_public_key';

  final data = TwoFAModel(
    id: 1,
    userId: 1,
    serverUrl: await Preferences().currentServer,
    // deviceId: 'SamsungA3UIac3',
    publicKey: publicKey,
    // serverId: 'unique_server_id-12345',
    timestamp: DateTime.now(),
    isMobileDevice: false,
  );

  // final key = Key.fromUtf8(privateKey);
  // final key = Key.fromBase16(privateKey);
  // final key = Key.fromSecureRandom(32);

  // final String openSSLKey = dotenv.env['OPEN_SSL_ENCRYPTION_KEY_32'] ?? '';
  // final key = enc.Key.fromBase64(openSSLKey);

  // print('key.base64');
  // print(key.base64);
  // print('key.base64 End key');

  // final plainText = data.serialize();

  // final key = Key.fromUtf8('QTsgvZ2NzZKFhQFVpHPt5pqqRernXS1F2gA/Pg2jeW8=');
  // final iv = IV.fromLength(16);
  // final String base64Iv = dotenv.env['OPEN_SSL_BASE_64_IV'] ?? '';
  // final iv = enc.IV.fromBase64(base64Iv);
  //
  // final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.cbc));

  // final encrypted = encrypter.encrypt(plainText, iv: iv);
  // final decrypted = encrypter.decrypt(encrypted, iv: iv);

  // print(decrypted);
  // print(encrypted.base64);
}
