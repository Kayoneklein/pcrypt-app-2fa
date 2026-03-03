import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pcrypt/2fa/index.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/config/configuration_bloc.dart';
import 'package:pcrypt/home/presentation/widgets/user_account_drawer_header.dart';
import 'package:pcrypt/model/language.dart';
import 'package:pcrypt/passwords/bloc/passwords.dart';
import 'package:pcrypt/sandbox/sandbox.dart' show ReadOnlySandbox;
import 'package:pcrypt/settings/bloc/settings.dart';
import 'package:pcrypt/settings/presentation/settings_screen.dart';
import 'package:pcrypt/tags/presentation/screens/tags_screen.dart';
import 'package:pcrypt/user_info/index.dart';
import 'package:pcrypt/util/localization.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthenticationBloc>(context);
    final passwordsBloc = BlocProvider.of<PasswordsBloc>(context);
    final authState = authBloc.state;

    final themeData = Theme.of(context);
    final primaryColor = themeData.primaryColor;
    final textStyle =
        themeData.textTheme.bodyMedium?.apply(color: primaryColor).copyWith(
              fontWeight: FontWeight.w500,
            );

    Widget _tile({
      required String text,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return ListTile(
        title: Text(
          text,
          style: textStyle,
        ),
        leading: Icon(
          icon,
          color: themeData.primaryColor,
        ),
        onTap: onTap,
      );
    }

    final tiles = <Widget>[
      if (authState is Authenticated)
        UserAccountDrawerHeader(user: authState.user),
      _tile(
        text: Strings.drawerMenuItemUserInfo,
        icon: FontAwesomeIcons.circleUser,
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(context,
              MaterialPageRoute<void>(builder: (context) => UserInfoScreen()));
        },
      ),

      const Divider(),
      _tile(
        text: Strings.drawerMenuItemSettings,
        icon: FontAwesomeIcons.gear,
        onTap: () async {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute<void>(
                  builder: (context) => BlocProvider(
                        create: (context) => SettingsBloc()..loadInitialState(),
                        child: SettingScreen(),
                      )));
          //  await AutofillService().requestSetAutofillService();
          // await Navigator.push(context, MaterialPageRoute<void>(builder: (context) => TagsScreen()));
          // passwordsBloc.add(RetryPressed());
        },
      ),
//      _tile(text: Strings.drawerMenuItemRestoreData, icon: FontAwesomeIcons.archive),
//      _tile(text: Strings.drawerMenuItemLogs, icon: FontAwesomeIcons.newspaper),
//      _tile(text: Strings.drawerMenuItemManageSubscription, icon: FontAwesomeIcons.calendar),
      const Divider(),
      _tile(
        text: Strings.drawerMenuItemTagsManager,
        icon: FontAwesomeIcons.tags,
        onTap: () async {
          Navigator.of(context).pop();
          await Navigator.push(context,
              MaterialPageRoute<void>(builder: (context) => TagsScreen()));
          passwordsBloc.add(RetryPressed());
        },
      ),
//      _tile(text: Strings.drawerMenuItemSecurity, icon: FontAwesomeIcons.shieldAlt),
      const Divider(),
      _tile(
        text: Strings.drawerMenuItemUserManual,
        icon: FontAwesomeIcons.bookOpen,
        onTap: () {
          Navigator.of(context).pop();
          final Language language = Localization.get.currentLanguage;
          launchUrl(Uri.parse(getManualUrl(context, language.code)));
        },
      ),

      const Divider(),
      _tile(
        text: 'Sandbox',
        icon: FontAwesomeIcons.server,
        onTap: () async {
          Navigator.of(context).pop();
          await Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (context) => const SandboxScreen()),
          );
        },
      ),
      // Padding(
      //   padding: const EdgeInsets.all(10.0),
      //   child: Row(
      //     children: [
      //       TextButton(
      //         onPressed: () {
      //           ReadOnlySandbox().addTeamShare();
      //           // ReadOnlySandbox().addUser();
      //         },
      //         child: Text('Save data'),
      //       ),
      //       TextButton(
      //         onPressed: () {
      //           ReadOnlySandbox().getEnc();
      //
      //           // ReadOnlySandbox().getUser();
      //         },
      //         child: Text('Get data'),
      //       ),
      //     ],
      //   ),
      // ),
    ];
    return Drawer(
      child: ListView(
        children: tiles,
      ),
    );
  }

  String getManualUrl(BuildContext context, String languageCode) =>
      BlocProvider.of<ConfigurationBloc>(context)
          .state
          .configuration
          .manualAppUrl
          ?.manuals
          .firstWhere(
            (element) => element.name == languageCode,
          )
          .link ??
      '';
}
