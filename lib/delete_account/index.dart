import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/util/settings.dart';
import 'package:pcrypt/util/snackbar.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/web/server_adapter.dart';
import 'package:pcrypt/web/web.dart';

import '../widget/custom_widgets.dart';

part 'presentation/delete_account.dart';

part 'bloc/delete_account_bloc.dart';

part 'bloc/delete_account_event.dart';

part 'bloc/delete_account_state.dart';
