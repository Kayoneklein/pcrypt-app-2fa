import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pcrypt/constants/api_routes.dart';
import 'package:pcrypt/constants/global_variables.dart';
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/model/configuration.dart';
import 'package:pcrypt/util/biometrics.dart';
import 'package:pcrypt/util/extensions.dart';
import 'package:pcrypt/util/localization.dart';
import 'package:pcrypt/util/settings.dart';
import 'package:pcrypt/web/scripts.dart';
import 'package:pcrypt/web/server_adapter.dart';
import 'package:pcrypt/web/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

/// Bloc that handles interactions on login screen
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginState.initial()) {
    on<LoginEvent>((event, emit) async {
      if (event is EmailChanged) {
        emit(state.copyWith(
          email: event.email,
          isEmailValid:
              (event.email != state.email) ? true : state.isEmailValid,
        ));
      }
      if (event is PasswordChanged) {
        emit(state.copyWith(
          password: event.password,
          isPasswordValid:
              (event.password != state.password) ? true : state.isPasswordValid,
        ));
      }
      if (event is PasswordVisibilityChanged) {
        emit(state.copyWith(
          isPasswordVisible: !state.isPasswordVisible,
        ));
      }
      if (event is AutoLogoutValueChanged) {
        emit(state.copyWith(
          autoLogout: event.value,
        ));
      }
      if (event is BiometricsAvailableChanged) {
        emit(state.copyWith(
          biometricsAvailable: event.enabled,
          isDeviceSupported: event.isDeviceSupported,
        ));
      }
      if (event is BiometricsCheckedChanged) {
        emit(state.copyWith(biometricsChecked: event.checked));

        final sharedPreferences = await SharedPreferences.getInstance();

        sharedPreferences.setBool(
          Settings.LOGIN_BIOMETRICS_CHECKBOX,
          event.checked,
        );
      }
      if (event is FormSubmitted) {
        final bool validEmail = state.email.isNotEmpty;
        final bool validPassword = state.password.isNotEmpty;
        if (validEmail && validPassword) {
          emit(state.copyWith(
            isLoading: true,
          ));
          _login(state.email, state.password, event.pin);
        } else {
          emit(state.copyWith(
            isEmailValid: validEmail,
            isPasswordValid: validPassword,
          ));
        }
      }
      if (event is FormSubmittedBioMatrix) {
        final bool validEmail = event.email?.isNotEmpty == true;
        final bool validPassword = event.password?.isNotEmpty == true;
        if (validEmail && validPassword) {
          emit(state.copyWith(
              isLoading: true, password: event.password, email: event.email));
          _login(event.email ?? '', event.password ?? '', event.pin);
        } else {
          emit(state.copyWith(
            isEmailValid: validEmail,
            isPasswordValid: validPassword,
          ));
        }
      }
      if (event is Login2faRequested) {
        emit(state.copyWith(
          isType2fa: true,
        ));
      }
      if (event is LoginResultReceived) {
        emit(state.copyWith(
          isLoading: false,
          loginStatus: event.status,
          errorMessage: event.errorMessage,
        ));
      }
      if (event is ErrorMessageViewed) {
        emit(state.copyWith(
          loginStatus: LoginStatus.none,
          errorMessage: '',
        ));
      }
      if (event is VeryFirstTimeLogin) {
        emit(state.copyWith(veryFirstTimeLogin: true));
      }
      if (event is AutomaticallyChangeCustomUrl) {
        emit(state.copyWith(isCustomServer: event.isCustomServer));
      }
    });

    _loadLoginData();
  }

  final ServerAdapter _server = ServerAdapter.get;
  final Settings _settings = Settings.get;

  final WebProvider _web = WebProvider.get;
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<String?> _getServerUrl(String email, String apiKey) async {
    try {
      const String path = ApiRoutes.lookUpServer;
      final String emailDomain = email.split('@')[1];
      final String url =
          '$path?apikey=${Uri.encodeQueryComponent(apiKey)}&domain=${Uri.encodeQueryComponent(emailDomain)}';
      final res = await _web.getClient(enforceDefaultDomain: true)?.get(url);
      final Map<String, dynamic> data = res?.data;

      final int err = data['error'] as int;
      if (err == 0) {
        final int changeServer = data['result']['changeserver'] as int;

        print('changeServer');
        print(changeServer);

        if (changeServer == 1) {
          ///Trigger a prompt for the user to select if they want to use
          ///The pcrypt.org server or their personal domain.
          final String server = data['result']['server'];
          return server;
        }
        throw 'Cannot change server now';
      }
      throw data['result'];
    } catch (err) {
      _web.makeErrorLog(null, err.toString());
      log('error from _getServerUrl in LoginBloc');
      log(err.toString());
      return null;
    }
  }

  Future<void> _checkCustomDomainUse({required String email}) async {
    final configResults = await WebProvider.get.getRemoteConfig();
    final RemoteConfiguration remoteConfiguration =
        configResults.data ?? RemoteConfiguration.initial;

    if (remoteConfiguration.disableConfigServer == false) {
      if (await _settings.getBoolean(Settings.IS_FROM_AUTO_FILL_REQUEST) !=
          true) {
        // final String? customServer =
        //     await _getServerUrl('klein@beast.dk', 'pcrypt');
        final String? customServer = await _getServerUrl(email, 'pcrypt');
        await _setCustomServer(
          server: customServer,
          isCustomServer: customServer != null,
        );

        // if (customServer == null) {
        //   await _web.changeServer(WebProvider.DEFAULT_SERVER);
        // }
      }
    }
  }

  Future<void> _setServerChange(String serverUrl, bool isCustomServer) async {
    final String previousServer = _web.currentServer;
    await _web.changeServer(serverUrl);

    /// Server validity check. If server can return the remote config - it is valid.
    await _server.cleanRemoteConfig();
    await _server.getRemoteConfig(
      onSuccess: (config) async {
        await _settings.setString(Settings.LOGIN_CUSTOM_SERVER_URL, serverUrl);
        await _settings.setBoolean(
            Settings.LOGIN_IS_CUSTOM_SERVER, isCustomServer);
        await JavaScripts.get.initialize();
        await Localization.get.changeLanguage(Localization.get.currentLanguage);
      },
      onError: (error) {
        _web.changeServer(previousServer);
      },
    );
  }

  Future _setCustomServer({
    String? server,
    required bool isCustomServer,
  }) async {
    String newServer;
    if (server != null && server.isNotEmpty) {
      if (server.isValidUrl()) {
        newServer = server;
      } else {
        newServer = 'https://$server';
      }
      await _setServerChange(newServer, isCustomServer);
      add(const AutomaticallyChangeCustomUrl(true));
    } else {
      newServer = WebProvider.DEFAULT_SERVER;
      add(const AutomaticallyChangeCustomUrl(false));
    }
  }

  //--------------------------------------------------------------------------------------------------------------------

  /// Attempt to log into the system
  // void _onSubmitPressed(String email, String password) {
  //   add(FormSubmittedBioMatrix(password: password, email: email));
  // }

  Future<void> _login(String email, String password, String? pin) async {
    await _checkCustomDomainUse(email: email);
    _server.login(
      email: email.trim(),
      password: password,
      pin: pin,
      onSuccess: (user) async {
        await _settings.setLoggedIn();
        await _settings.setCurrentUser(user);
        await _saveLoginData();
        add(const LoginResultReceived(
          status: LoginStatus.success,
        ));
        // get global emergency status
        _getGlobalEmergencyStatus(password);
      },
      onPinCodeRequired: () {
        add(const LoginResultReceived(
          status: LoginStatus.pinCodeRequired,
        ));
      },
      onType2faRequired: () {
        add(Login2faRequested());
      },
      onError: (error) {
        if (error.isUnknownUser) {
          add(const LoginResultReceived(
            status: LoginStatus.unknownUser,
          ));
        } else if (error.isInvalidPassword) {
          add(const LoginResultReceived(
            status: LoginStatus.invalidPassword,
          ));
        } else if (error.isEmailNotVerified) {
          add(const LoginResultReceived(
            status: LoginStatus.emailNotVerified,
          ));
        } else if (error.isConnectionError) {
          add(LoginResultReceived(
            status: LoginStatus.otherError,
            errorMessage: error.message,
          ));
        } else {
          add(LoginResultReceived(
            status: LoginStatus.otherError,
            errorMessage: error.message,
          ));
        }
      },
    );
  }

  /// Save latest login settings
  Future<void> _saveLoginData() async {
    await _settings.setString(Settings.LOGIN_LATEST_EMAIL, state.email);
    await _settings.setBoolean(Settings.readonlyMode, false);
    // await _settings.setString(Settings.LOGIN_LATEST_PASSWORD, state.password);
    await _settings.setString(
        Settings.LOGIN_AUTO_LOGOUT, state.autoLogout.index.toString());
    await _settings.setBoolean(
        Settings.LOGIN_BIOMETRICS_CHECKBOX, state.biometricsChecked);
  }

  /// Load latest login settings
  Future<void> _loadLoginData() async {
    final pref = Preferences();

    final configResults = await WebProvider.get.getRemoteConfig();
    final RemoteConfiguration remoteConfiguration =
        configResults.data ?? RemoteConfiguration.initial;

    if (await pref.isFromAutofill != true) {
      if (remoteConfiguration.disableConfigServer == false) {
        if (await pref.firstTimeLoginServer != true) {
          add(VeryFirstTimeLogin());
        }
      }
    }

    final latestLogin = await pref.latestEmail ?? '';

    if (latestLogin != state.email) {
      add(EmailChanged(email: latestLogin));
    }

    final autoLogout =
        AutoLogoutTimer.values[int.parse(await pref.autoLogout ?? '0')];
    if (autoLogout != state.autoLogout) {
      add(AutoLogoutValueChanged(value: autoLogout));
    }
    final biometricsAvailable = BiometricsService.get.canCheckBiometrics;
    final isDeviceSupported = BiometricsService.get.isDeviceSupported;
    final biometricsChecked = await pref.biometricCheckbox;
    if (biometricsChecked != null && biometricsChecked == true) {
      // final authorized = await BiometricsService.get.authorize();
      // await Future<void>.delayed(const Duration(milliseconds: 100));
      // await _settings.setString(Settings.LOGIN_LATEST_EMAIL, latestLogin);
      // final latestLoginPassword = pref.latestPass ?? '';
      // if (authorized) {
      //   _onSubmitPressed(latestLogin, latestLoginPassword);
      // } else {
      //   await _settings.setString(Settings.LOGIN_LATEST_EMAIL, latestLogin);
      //   await _settings.setString(
      //       Settings.LOGIN_LATEST_PASSWORD, latestLoginPassword);
      // }
      add(BiometricsAvailableChanged(
        enabled: biometricsAvailable,
        isDeviceSupported: isDeviceSupported,
      ));
      add(BiometricsCheckedChanged(
        checked: biometricsAvailable && biometricsChecked == true,
      ));
    } else {
      add(BiometricsAvailableChanged(
        enabled: biometricsAvailable,
        isDeviceSupported: isDeviceSupported,
      ));
      add(BiometricsCheckedChanged(
        checked: biometricsAvailable,
      ));
    }
  }

  void _getGlobalEmergencyStatus(String password) {
    _server.getGlobalEmergencyStatus(
      onError: (error) {
        if (kDebugMode) {
          print(error);
        }
      },
      onSuccess: (status) {
        if (kDebugMode) {
          print('getGlobalEmergencyStatus onSuccess: $status');
        }
        if (status) {
          // do nothing
          return;
        }
        // make other api calls
        _server.getGlobalEmergencySetup(
          password,
          onSuccess: () {
            if (kDebugMode) {
              print('getGlobalEmergencySetup onSuccess');
            }
          },
          onError: (error) {
            if (kDebugMode) {
              print(error);
            }
          },
        );
      },
    );
  }
}
