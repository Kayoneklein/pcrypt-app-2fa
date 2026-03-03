import 'dart:convert';
import 'dart:developer' as dev;

import 'package:http/http.dart' as http;
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/model/api_response.dart';

class HTTPService2FA {
  HTTPService2FA._();

  static final HTTPService2FA get = HTTPService2FA._();

  // final Map<String, String> _headers = {
  //   'Accept': 'application/json',
  //   'Content-Type': 'application/json',
  // };

  final _baseUrl = 'https://pcrypt-vanilla-php-2fa.onrender.com/api/v1';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': '${Preferences().twoFaAuthToken}',
        //   'X-Tfa': Preferences().twoFAKey ?? '',
        //   'X-Device': Preferences().deviceId ?? '',
      };

  Future<ApiResponse> getData(String path) async {
    int? statusCode;
    try {
      final request = await http.get(
        Uri.parse(_baseUrl + path),
        headers: _headers,
      );

      statusCode = request.statusCode;
      final body = jsonDecode(request.body);
      if (statusCode >= 200 && statusCode <= 205) {
        return ApiResponse(body: body['data'], status: true);
      }

      throw body;
    } catch (err) {
      dev.log('$err: error from get request in getData() in HTTPService2FA');
      return ApiResponse(body: err, status: false, statusCode: statusCode);
    }
  }

  Future<ApiResponse> postData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    int? statusCode;
    try {
      final request = await http.post(
        Uri.parse(_baseUrl + path),
        body: jsonEncode(data),
        headers: _headers,
      );

      statusCode = request.statusCode;

      final body = jsonDecode(request.body);

      if (statusCode >= 200 && statusCode <= 205) {
        return ApiResponse(body: body['data'], status: true);
      }
      throw body;
    } catch (err) {
      dev.log('$err: error from get request in postData() in HTTPService2FA');
      return ApiResponse(body: err, status: false, statusCode: statusCode);
    }
  }

  Stream<ApiResponse> detectNewDevice(
      {Duration interval = const Duration(seconds: 3)}) async* {
    while (true) {
      try {
        final response = await getData('/2fa/new-device');
        yield response;
      } catch (e) {
        yield ApiResponse(body: e.toString(), status: false);
      }
      await Future.delayed(interval);
    }
  }
}
