import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pcrypt/2fa/bloc/2fa_bloc.dart';
import 'package:pcrypt/2fa/bloc/2fa_state.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/model/api_response.dart';
import 'package:pcrypt/model/security_data.dart';
import 'package:pcrypt/util/encrypt.dart';
import 'package:pcrypt/web/web.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'bloc/2fa_event.dart';
import 'services/2fa_http_service.dart';

part '2fa.dart';

part 'screens/qr_scan.dart';

part 'screens/sandbox.dart';

part 'screens/qr_code_display.dart';

part 'widgets/action_button.dart';
