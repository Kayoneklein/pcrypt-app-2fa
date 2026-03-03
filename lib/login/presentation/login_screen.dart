part of '../index.dart';

///Screen for logging into the app
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(Strings.loginTitle),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(FontAwesomeIcons.circleQuestion),
            tooltip: Strings.actionGuide,
            onPressed: () {
              BlocProvider.of<AuthenticationBloc>(context)
                  .add(GuideRequestedEvent());
            },
          ),
          if (!BlocProvider.of<ConfigurationBloc>(context)
              .state
              .configuration
              .disableConfigServer)
            IconButton(
              icon: const Icon(FontAwesomeIcons.gear),
              tooltip: Strings.actionSettings,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) {
                  return LoginSettingsScreen();
                }));
              },
            ),
        ],
      ),
      body: SafeArea(
        child: BlocProvider(
          create: (context) => LoginBloc(),
          child: LoginForm(),
        ),
      ),
    );
  }
}
