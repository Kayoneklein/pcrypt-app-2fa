import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pcrypt/authentication/bloc/authentication_bloc.dart';
import 'package:pcrypt/authentication/bloc/authentication_event.dart';
import 'package:pcrypt/constants/colors.dart';
import 'package:pcrypt/delete_account/index.dart';
import 'package:pcrypt/model/user.dart';
import 'package:pcrypt/util/settings.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/web/server_adapter.dart';
import 'package:pcrypt/widget/custom_widgets.dart';

part 'bloc/user_info_bloc.dart';

part 'bloc/user_info_event.dart';

part 'bloc/user_info_state.dart';

part 'presentation/user_info_screen.dart';
