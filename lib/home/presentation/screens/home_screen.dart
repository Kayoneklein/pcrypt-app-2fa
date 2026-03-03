import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart' as auth;
import 'package:pcrypt/config/configuration_bloc.dart';
import 'package:pcrypt/home/bloc/tab.dart';
import 'package:pcrypt/home/presentation/widgets/application_drawer.dart';
import 'package:pcrypt/home/presentation/widgets/home_tab_selector.dart';
import 'package:pcrypt/messages/bloc/messages.dart';
import 'package:pcrypt/messages/presentation/screens/message_edit_screen.dart';
import 'package:pcrypt/messages/presentation/screens/messages_screen.dart';
import 'package:pcrypt/messages/presentation/widgets/messages_app_bar.dart';
import 'package:pcrypt/model/password.dart';
import 'package:pcrypt/notifications/bloc/notifications.dart';
import 'package:pcrypt/notifications/presentation/screens/notifications_screen.dart';
import 'package:pcrypt/passwords/bloc/passwords.dart';
import 'package:pcrypt/passwords/presentation/screens/password_edit_screen.dart';
import 'package:pcrypt/passwords/presentation/screens/passwords_screen.dart';
import 'package:pcrypt/passwords/presentation/widgets/passwords_app_bar.dart';
import 'package:pcrypt/passwords/presentation/widgets/passwords_share_info.dart';
import 'package:pcrypt/sharing/presentation/screens/member_picker_screen.dart';
import 'package:pcrypt/util/strings.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _lastBackPressedTime = DateTime.now();
  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    final remoteConfig =
        BlocProvider.of<ConfigurationBloc>(context).state.configuration;
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (bool? pop, result) {
        _onBackPressed();
        if (canPop) {
          BlocProvider.of<auth.AuthenticationBloc>(context)
              .add(auth.SessionExpiredEvent());
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TabBloc>(create: (context) => TabBloc()),
          BlocProvider<PasswordsBloc>(create: (context) {
            return PasswordsBloc(
              isPremium: BlocProvider.of<auth.AuthenticationBloc>(context)
                  .isPremiumFeaturesAvailable,
              configuration: remoteConfig,
              authBloc: BlocProvider.of<auth.AuthenticationBloc>(context),
            );
          }),
          BlocProvider<MessagesBloc>(create: (context) => MessagesBloc()),
          BlocProvider<NotificationsBloc>(
              create: (context) => NotificationsBloc()),
        ],
        child: BlocConsumer<auth.AuthenticationBloc, auth.AuthenticationState>(
          listener: (ctx, authState) {
            if (authState is auth.SessionExpired) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
              BlocProvider.of<auth.AuthenticationBloc>(context)
                  .add(auth.SignedOutEvent());
            }
          },
          builder: (ctx, authState) {
            return BlocBuilder<TabBloc, AppTab>(
              builder: (context, activeTab) {
                return Scaffold(
                  appBar: _appBarForTab(activeTab),
                  drawer: ApplicationDrawer(),
                  endDrawer: _endDrawerForTab(activeTab),
                  drawerEdgeDragWidth: 0.0,
                  body: _bodyForTab(activeTab),
                  bottomNavigationBar: Builder(
                    builder: (context) {
                      return HomeTabSelector(
                        tabs: <AppTab>[
                          AppTab.passwords,
                          if (BlocProvider.of<auth.AuthenticationBloc>(context)
                                  .isVerifiedFeaturesAvailable &&
                              !remoteConfig.disableMessages)
                            AppTab.messages,
                          AppTab.notifications,
                        ],
                        activeTab: activeTab,
                        onTabSelected: (AppTab tab) {
                          if (Scaffold.of(context).isDrawerOpen) {
                            Navigator.pop(context);
                          }
                          BlocProvider.of<TabBloc>(context).add(UpdateTab(tab));
                          if (tab == AppTab.notifications) {
                            BlocProvider.of<NotificationsBloc>(context)
                                .add(NotificationsTabOpened());
                          }
                        },
                      );
                    },
                  ),
                  floatingActionButton: _fabForTab(activeTab),
                );
              },
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _appBarForTab(AppTab activeTab) {
    switch (activeTab) {
      case AppTab.passwords:
        return PasswordsAppBar();
      case AppTab.messages:
        return MessagesAppBar();
      case AppTab.notifications:
        return AppBar(
          title: Text(Strings.notificationsTitle),
        );
      default:
        return AppBar();
    }
  }

  Widget? _fabForTab(AppTab activeTab) {
    switch (activeTab) {
      case AppTab.passwords:
        return BlocBuilder<PasswordsBloc, PasswordsState>(
          builder: (context, state) {
            if (state.isPasswordsAvailable) {
              return FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () =>
                    _addNewPassword(context, state.totalFilesUploaded),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      case AppTab.messages:
        return BlocBuilder<MessagesBloc, MessagesState>(
          builder: (context, state) {
            if (state.isMessagesAvailable) {
              return FloatingActionButton(
                child: const Icon(Icons.message),
                onPressed: () => _addNewMessage(context),
              );
            } else {
              return const SizedBox();
            }
          },
        );
      default:
        return null;
    }
  }

  Widget? _endDrawerForTab(AppTab activeTab) {
    switch (activeTab) {
      case AppTab.passwords:
        return PasswordsShareInfoDrawer();
      default:
        return null;
    }
  }

  Widget _bodyForTab(AppTab activeTab) {
    switch (activeTab) {
      case AppTab.passwords:
        return PasswordsScreen();
      case AppTab.messages:
        return MessagesScreen();
      case AppTab.notifications:
        return NotificationsScreen();
      default:
        return Container();
    }
  }

  //--------------------------------------------------------------------------------------------------------------------

  /// Initiate new password creation screen
  Future<void> _addNewPassword(
      BuildContext context, int totalFilesAttached) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<Password>(
        builder: (context) => PasswordEditScreen(
          totalFilesAttached: totalFilesAttached,
        ),
      ),
    );
    if (result != null) {
      BlocProvider.of<PasswordsBloc>(context)
          .add(PasswordAddPressed(password: result));
    }
  }

  /// Initiate new message creation screen
  Future<void> _addNewMessage(BuildContext context) async {
    final members = await Navigator.push(
      context,
      MaterialPageRoute<MemberPickerModel>(
        builder: (context) => const MemberPickerScreen(),
      ),
    );
    if (members != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute<MessageResult>(
          builder: (context) =>
              MessageEditScreen(members: members.membersToSend),
        ),
      );
      if (result is MessageSendResult) {
        BlocProvider.of<MessagesBloc>(context)
            .add(MessageSendPressed(message: result.message));
      }
    }
  }

  bool _onBackPressed() {
    final difference = DateTime.now().difference(_lastBackPressedTime);
    _lastBackPressedTime = DateTime.now();
    if (difference >= const Duration(milliseconds: 700)) {
      canPop = false;
      return false;
    } else {
      SystemNavigator.pop(animated: true);
      canPop = true;
      return true;
    }
  }
}
