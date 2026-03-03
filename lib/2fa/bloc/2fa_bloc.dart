import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/2fa/bloc/2fa_event.dart';
import 'package:pcrypt/2fa/bloc/2fa_state.dart';
import 'package:pcrypt/2fa/services/2fa_http_service.dart';
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/model/api_response.dart';
import 'package:pcrypt/model/security_data.dart';
import 'package:pcrypt/util/device_info.dart';
import 'package:pcrypt/util/encrypt.dart';
import 'package:pcrypt/util/settings.dart';
import 'package:pcrypt/web/web.dart';

class TwoFABloc extends Bloc<TwoFAEvents, TwoFAState> {
  TwoFABloc() : super(Initial2FAState()) {
    try {
      on<TwoFAEvents>((event, emit) async {
        if (event is Register2FaAccount) {
          try {
            final email = await Preferences().latestEmail;
            final Map<String, dynamic> json = {
              'password': '123456',
              'email': email,
              'name': 'Firstname Lastname',
            };
            emit(state.copyWith(
              isLoading: true,
              errorMessage: '',
              successMessage: '',
              email: email,
            ));
            final req = await HTTPService2FA.get.postData(
              path: '/users/register',
              data: json,
            );
            emit(state.copyWith(isLoading: false));

            if (req.status) {
              final SecurityUser data = SecurityUser.fromJson(req.body['user']);
              emit(state.copyWith(
                securityUser: data,
                successMessage: 'Registration successful',
              ));
            } else {
              emit(state.copyWith(errorMessage: req.body['message']));
            }
          } catch (err) {
            emit(state.copyWith(
              isLoading: false,
              errorMessage: err.toString(),
              successMessage: '',
            ));
          }
        }

        if (event is Activate2FA) {
          try {
            emit(state.copyWith(
              isLoading: true,
              errorMessage: '',
              successMessage: '',
            ));

            final req = await _activate2Fa(path: 'activate');

            if (req.status == false) {
              emit(state.copyWith(
                errorMessage: req.body['message'],
                successMessage: '',
                isLoading: false,
              ));
            } else {
              final twoFa = await _getTwoFaUser();
              emit(state.copyWith(
                errorMessage: '',
                successMessage: '2FA activated on your account',
                twoFa: twoFa,
                isLoading: false,
              ));
            }
          } catch (err) {
            dev.log(err.toString());
            emit(state.copyWith(
              isLoading: false,
              errorMessage: err.toString(),
            ));
          }
        }
        if (event is LoginWith2FA) {
          try {
            print('Preferences.pref.twoFAKey');
            print(Preferences().twoFAKey);
            print('Preferences.pref.twoFaAuthToken');
            print(Preferences().twoFaAuthToken);
            print('Preferences.pref.deviceId');
            print(Preferences().deviceId);
            print('=================');
            final enc =
                Encryption().decrypt(await Preferences().twoFAKey ?? '');
            final json = jsonDecode(enc);
            json['is_mobile_device'] = false;
            final webPayload = Encryption().encrypt(jsonEncode(json));
            print('webPayload');
            print(webPayload);
          } catch (e) {}

          try {
            emit(state.copyWith(
              isLoading: true,
              errorMessage: '',
              successMessage: '',
            ));

            final req = await HTTPService2FA.get.postData(
              path: '/users/login',
              data: {
                'password': '123456',
                'email': state.email,
              },
            );

            if (req.status) {
              final SecurityUser data = SecurityUser.fromJson(req.body['user']);

              final String token = req.body['access_token'];

              await Settings.get.setString(Settings.twoFaAuthToken, token);

              final twoFa = await _getTwoFaUser();

              emit(state.copyWith(
                securityUser: data,
                successMessage: 'Login successful',
                isLoading: false,
                twoFa: twoFa,
                newDeviceDetected: false,
              ));
            } else {
              bool isUnauthorized = false;
              final String error = req.body['message'];
              // const serverMessage =
              //     'An unauthorized device is trying to access your account. Please verify device.';
              const serverMessage1 =
                  'This device cannot access this account now';
              if (error.contains('unauthorized')) {
                isUnauthorized = true;
              }
              if (error == serverMessage1) {
                isUnauthorized = true;
              }
              // if(req.statusCode == 403){
              //   isUnauthorized = true;
              // }

              emit(state.copyWith(
                errorMessage: error,
                successMessage: '',
                isLoading: false,
                newDeviceDetected: isUnauthorized,
              ));
            }
          } catch (err) {
            emit(state.copyWith(
              isLoading: false,
              errorMessage: err.toString(),
            ));
          }
        }

        if (event is ResetDeviceDetectedProperty) {
          emit(state.copyWith(
            newDeviceDetected: false,
            errorMessage: '',
            successMessage: '',
          ));
        }

        if (event is DispatchErrorMessage) {
          emit(state.copyWith(
            successMessage: '',
            errorMessage: event.message,
          ));
        }

        if (event is CancelLoginRequest) {
          try {
            emit(state.copyWith(isLoading: true));
            final res = await HTTPService2FA.get.postData(
              path: '/2fa/cancel-device-login',
              data: {},
            );
            if (res.status) {
              emit(state.copyWith(
                isLoading: false,
                successMessage: 'Login request cancelled on the new device',
              ));
              return;
            }
            throw res.body['message'];
          } catch (err) {
            dev.log('Error from CancelLoginRequest: $err');
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: err.toString(),
                successMessage: '',
              ),
            );
          }
        }
        if (event is BlockDevice) {
          try {
            emit(state.copyWith(isLoading: true));
            final res = await HTTPService2FA.get.postData(
              path: '/2fa/block-device',
              data: {},
            );
            if (res.status) {
              emit(state.copyWith(
                isLoading: false,
                successMessage:
                    'You have permanently blocked the new device from accessing this account',
              ));
              return;
            }
            throw res.body['message'];
          } catch (err) {
            dev.log('Error from BlockDevice: $err');
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: err.toString(),
                successMessage: '',
              ),
            );
          }
        }
        if (event is ScanQRCode) {
          try {
            emit(state.copyWith(isLoading: true));
            final res = await HTTPService2FA.get.postData(
              path: '/2fa/change-device',
              data: {'payload': event.payload},
            );
            if (res.status) {
              final token = res.body['access_token'];
              final twoFaSecKey = res.body['two_fa'];

              await Settings.get.setString(Settings.twoFaAuthToken, token);
              await Settings.get.setString(Settings.twoFaSecKey, twoFaSecKey);

              add(LoginWith2FA());
            } else {
              if (res.body != null && res.body['message'] != null) {
                throw res.body['message'];
              }
            }
          } catch (err) {
            dev.log('Error from ScanQRCode: $err');
            emit(
              state.copyWith(
                isLoading: false,
                errorMessage: err.toString(),
                successMessage: '',
              ),
            );
          }
        }
      });
    } catch (err) {
      print('err');
      print(err);
    }
  }
}

Future _healthcheck() async {
  final res = await HTTPService2FA.get.getData('/healthcheck');
  print(res.body);
}

Future<ApiResponse> _activate2Fa({
  required String path,
}) async {
  final deviceId = await getDeviceId();

  final data = TwoFAModel(
    deviceId: deviceId,
    publicKey: 'random_public_key',
    serverUrl: WebProvider.get.currentServer,
    isMobileDevice: true,
    deviceToken: 'device_token', //todo: add an fcmToken
  );
  final json = data.toJson();

  final stringJson = jsonEncode(json);
  final encrypt = Encryption().encrypt(stringJson);

  final req = await HTTPService2FA.get.postData(
    path: '/2fa/$path',
    data: {
      'payload': encrypt,
    },
  );

  if (req.status) {
    final String twoFaKey = req.body;
    await Settings.get.setString(Settings.twoFaSecKey, twoFaKey);
  }

  return req;
}

Future<TwoFAModel?> _getTwoFaUser() async {
  try {
    final userReq = await HTTPService2FA.get.getData('/users');

    if (!userReq.status) {
      // dev.log('Error getting user data =====>');
      // dev.log(userReq.body.toString());
    } else {
      final twoFaString = userReq.body['two_fa'];
      if (twoFaString != null) {
        final decrypted = Encryption().decrypt(twoFaString);
        final json = jsonDecode(decrypted);
        return TwoFAModel.fromJson(json);
      }
    }
    throw userReq.body['message'];
  } catch (err) {
    // dev.log(err.toString());
    return null;
  }
}
