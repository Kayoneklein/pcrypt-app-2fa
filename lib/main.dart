import 'dart:async';
import 'dart:developer';

import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pcrypt/2fa/bloc/2fa_bloc.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/config/configuration_bloc.dart';
import 'package:pcrypt/constants/global_variables.dart';
import 'package:pcrypt/delete_account/index.dart';
import 'package:pcrypt/home/presentation/screens/home_screen.dart';
import 'package:pcrypt/home/presentation/screens/splash_screen.dart';
import 'package:pcrypt/login/bloc/login_bloc.dart';
import 'package:pcrypt/login/bloc/login_settings_bloc.dart';
import 'package:pcrypt/login/index.dart';
import 'package:pcrypt/login/presentation/signup_screen.dart';
import 'package:pcrypt/util/biometrics.dart';
import 'package:pcrypt/util/device_info.dart';
import 'package:pcrypt/util/encrypt.dart';
import 'package:pcrypt/util/settings.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/widget/lifecycle_manager.dart';
import 'package:privacy_screen/privacy_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'home/presentation/screens/guide_screen.dart';

final Settings _settings = Settings.get;

WebViewController? webViewController;

void main() async {
  runZonedGuarded<Future<void>>(() async {
    await initGeneralSetup();

    runApp(MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc()..add(AppStartedEvent()),
        ),
        BlocProvider<ConfigurationBloc>(
          create: (context) => ConfigurationBloc(),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
        ),
        BlocProvider<LoginSettingsBloc>(
          create: (context) => LoginSettingsBloc(),
        ),
        BlocProvider<DeleteAccountBloc>(
          create: (context) => DeleteAccountBloc(),
        ),
        BlocProvider<TwoFABloc>(
          create: (context) => TwoFABloc(),
        ),
      ],
      child: PCryptApp(),
    ));
  },
      (error,
          stack) {}); //, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

@pragma('vm:entry-point')
Future<void> autofillEntryPoint() async {
  log('dart side: autofillEntrypoint');
  await initGeneralSetup(fromAutofill: true, fromSavePass: false);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc()..add(AppStartedEvent()),
      ),
      BlocProvider<ConfigurationBloc>(
        create: (context) => ConfigurationBloc(),
      ),
      BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(),
      ),
      BlocProvider<LoginSettingsBloc>(
        create: (context) => LoginSettingsBloc(),
      ),
      BlocProvider<DeleteAccountBloc>(
        create: (context) => DeleteAccountBloc(),
      ),
    ],
    child: PCryptApp(),
  ));
  //, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

@pragma('vm:entry-point')
Future<void> savePasswordEntryPoint() async {
  log('==========> in dart: savePasswordEntryPoint');
  await initGeneralSetup(fromAutofill: false, fromSavePass: true);

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<AuthenticationBloc>(
        create: (context) => AuthenticationBloc()..add(AppStartedEvent()),
      ),
      BlocProvider<ConfigurationBloc>(
        create: (context) => ConfigurationBloc(),
      ),
      BlocProvider<LoginBloc>(
        create: (context) => LoginBloc(),
      ),
      BlocProvider<LoginSettingsBloc>(
        create: (context) => LoginSettingsBloc(),
      ),
      BlocProvider<DeleteAccountBloc>(
        create: (context) => DeleteAccountBloc(),
      ),
    ],
    child: PCryptApp(),
  ));
  //,
  // }, (error,stack) {}); //, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

Future<void> _enablePrivacyScreen() async {
  await PrivacyScreen.instance.enable(
    iosOptions: const PrivacyIosOptions(
      enablePrivacy: true,
    ),
    androidOptions: const PrivacyAndroidOptions(
      enableSecure: true,
    ),
    backgroundColor: Colors.white.withAlpha(0),
    blurEffect: PrivacyBlurEffect.extraLight,
  );
}

class PCryptApp extends StatefulWidget {
  @override
  State<PCryptApp> createState() => _PCryptAppState();

  /// Creates a [MaterialColor] based on the supplied [Color]
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class _PCryptAppState extends State<PCryptApp> with WidgetsBindingObserver {
  bool _bioAuthCausedLogoutDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    final OverlayEntry _biometricsOverlay = OverlayEntry(
      builder: (context) =>
          Container(color: Theme.of(context).colorScheme.secondary),
    );

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    return LifeCycleManager(
      onStateChanged: (state) => _onStateChanged(context, state),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        // title: 'Password Crypt',
        theme: _buildThemeData(),
        builder: (_, child) {
          return PrivacyGate(
            child: child,
          );
        },
        home: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) async {
            if (state is ShowUnverifiedEmailDialog) {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(Strings.unverifiedEmailTitle),
                    content: Text(Strings.unverifiedEmailMessage),
                    actions: [
                      TextButton(
                        child: Text(Strings.actionOk.toUpperCase()),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  );
                },
              );
            } else if (state is ShowAuthenticationDialog) {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(SignedOutEvent());
              _showDialogForLoggedOut(context);
            }
            if (state is SessionExpired) {
              await showDialog<void>(
                  context: context,
                  builder: (context) {
                    return PopScope(
                      canPop: false,
                      onPopInvokedWithResult: (bool? pop, result) {},
                      child: AlertDialog(
                        title: Text(Strings.sessionExpiredTitle),
                        content: Text(Strings.sessionExpiredMessage),
                        actions: <Widget>[
                          TextButton(
                            child: Text(Strings.actionOk.toUpperCase()),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    );
                  });
              Navigator.of(context).popUntil(ModalRoute.withName('/'));
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(SignedOutEvent());
            } else if (state is BiometricLock) {
              Overlay.of(context).insert(_biometricsOverlay);
              await Future<void>.delayed(const Duration(milliseconds: 100));
              final authorized = await BiometricsService.get.authorize();
              _biometricsOverlay.remove();
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(BiometricInputEvent(authorized: authorized));
            }
          },
          child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              Widget widget;
              SystemUiOverlayStyle overlayStyle;
              if (state is Uninitialized) {
                widget = SplashScreen();
                overlayStyle = SystemUiOverlayStyle.dark.copyWith(
                  systemNavigationBarColor: Theme.of(context).primaryColor,
                  systemNavigationBarIconBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                );
              } else if (state is StartupGuide) {
                widget = GuideScreen();
                overlayStyle = SystemUiOverlayStyle.dark.copyWith(
                  systemNavigationBarColor: Colors.blue[900],
                  systemNavigationBarIconBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                );
              } else if (state is Authenticated ||
                  state is ShowPremiumFeaturesDialog ||
                  state is ShowUnverifiedEmailDialog ||
                  state is BiometricLock ||
                  state is SessionExpired) {
                overlayStyle = SystemUiOverlayStyle.dark.copyWith(
                  systemNavigationBarColor: Theme.of(context).primaryColor,
                  systemNavigationBarIconBrightness: Brightness.light,
                  statusBarIconBrightness: Brightness.light,
                );
                widget = HomeScreen();
                overlayStyle = SystemUiOverlayStyle.light.copyWith(
                  systemNavigationBarColor: Colors.grey[50],
                  systemNavigationBarIconBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark,
                );
              } else if (state is SigningUp) {
                widget = SignUpScreen();
                overlayStyle = SystemUiOverlayStyle.light.copyWith(
                  systemNavigationBarColor: Colors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark,
                );
              } else {
                widget = LoginScreen();
                _showDialogForLoggedOut(context);
                overlayStyle = SystemUiOverlayStyle.light.copyWith(
                  systemNavigationBarColor: Colors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.dark,
                );
              }
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: overlayStyle,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: widget,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showDialogForLoggedOut([BuildContext? ctx]) async {
    final bioAuthCausedLogout =
        await _settings.getString(Settings.LOGOUT_DUE_TO_BIO_AUTH) == 'true';
    if (bioAuthCausedLogout && !_bioAuthCausedLogoutDialogShowing) {
      _bioAuthCausedLogoutDialogShowing = true;
      showDialog<void>(
        context: ctx ?? context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('User Logged Out'),
            content: Text(
              bioAuthCausedLogout ? Strings.messageBioAuthCancelled : '',
            ),
            actions: [
              TextButton(
                child: Text(Strings.actionOk.toUpperCase()),
                onPressed: () {
                  _bioAuthCausedLogoutDialogShowing = false;
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _onStateChanged(BuildContext context, AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        BlocProvider.of<AuthenticationBloc>(context).add(AppPausedEvent());
        break;
      case AppLifecycleState.resumed:
        BlocProvider.of<AuthenticationBloc>(context).add(AppResumedEvent());
        break;
      case AppLifecycleState.detached:

        ///THIS IS NOT CALLED WHEN THE APP IS CLOSED IMMEDIATELY
        BlocProvider.of<AuthenticationBloc>(context).add(SignedOutEvent());
        break;
      default:
        break;
    }
  }

  ThemeData _buildThemeData() {
    final textTheme = Theme.of(context).textTheme;

    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: Colors.blue,
      textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
        bodySmall: const TextStyle(fontSize: 13.0),
        bodyMedium: const TextStyle(fontSize: 16.0),
        bodyLarge: const TextStyle(fontSize: 16.0),
      ),
      primaryTextTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodySmall: TextStyle(fontSize: 13.0),
        bodyMedium: TextStyle(fontSize: 16.0),
        bodyLarge: TextStyle(fontSize: 16.0),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        //brightness: Brightness.dark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.blue,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.blue,
      ),
      useMaterial3: false,
      tabBarTheme: const TabBarThemeData(
        indicatorColor: Colors.blue,
      ),
      primaryColorLight: Colors.blue,
      chipTheme: const ChipThemeData(
        brightness: Brightness.light,
        padding:
            EdgeInsets.only(left: 12.0, right: 12.0, top: 4.0, bottom: 4.0),
        labelPadding: EdgeInsets.all(0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(
              color: Colors.blue, width: 2.0, style: BorderStyle.solid),
        ),
        backgroundColor: Colors.transparent,
        labelStyle: TextStyle(fontSize: 14.0, color: Colors.blue),
        selectedColor: Colors.blue,
        secondaryLabelStyle: TextStyle(fontSize: 14.0, color: Colors.black),
        disabledColor: Colors.grey,
        secondarySelectedColor: Colors.blue,
      ),
    );
  }
}

Future<void> _saveDeviceId() async {
  final deviceId = await getDeviceId();
  final encryptedDeviceId = Encryption().encrypt(deviceId ?? '');
  await Settings.get.setString(Settings.deviceId, encryptedDeviceId);
}

Future<void> initGeneralSetup(
    {bool fromAutofill = false, bool fromSavePass = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initHyphenation();

  await _settings.setBoolean(Settings.IS_FROM_AUTO_FILL_REQUEST, fromAutofill);
  await _settings.setBoolean(Settings.IS_FROM_SAVE_PASSWORD, fromSavePass);
  await _saveDeviceId();

  //await Firebase.initializeApp();
  await _enablePrivacyScreen();
  if (kDebugMode) {
    // Force disable Crashlytics collection while doing every day development.
    // Temporarily toggle this to true if you want to test crash reporting in your app.
    // raf
    //await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  }
  // raf
  //FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}
