import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pcrypt/authentication/bloc/authentication.dart';
import 'package:pcrypt/config/configuration_bloc.dart';
import 'package:pcrypt/constants/assets.dart';
import 'package:pcrypt/constants/colors.dart' show PColors;
import 'package:pcrypt/constants/global_variables.dart';
import 'package:pcrypt/home/presentation/widgets/notifying_page_view.dart';
import 'package:pcrypt/home/presentation/widgets/page_indicator.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/widget/custom_widgets.dart';

///Screen for displaying startup guide
class GuideScreen extends StatefulWidget {
  final _guidePages = <MapEntry<String, String>>[
    MapEntry(Strings.tourGuideTitle1, Strings.tourGuideMessage1),
    MapEntry(Strings.tourGuideTitle2, Strings.tourGuideMessage2),
    MapEntry(Strings.tourGuideTitle3, Strings.tourGuideMessage3),
    MapEntry(Strings.tourGuideTitle4, Strings.tourGuideMessage4),
    MapEntry(Strings.tourGuideTitle5, Strings.tourGuideMessage5),
    MapEntry(Strings.tourGuideTitle6, Strings.tourGuideMessage6),
  ];

  @override
  State createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final _notifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remoteConfig =
        BlocProvider.of<ConfigurationBloc>(context).state.configuration;
    final theme = Theme.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        // Android
        statusBarBrightness: Brightness.light,
        // iOS
        statusBarColor: PColors.darkBlue,
        systemNavigationBarColor: PColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                // left: 180.0,
                // right: 180.0,
                top: 54.0,
                bottom: 40.0,
              ),
              child: Container(
                width: 180,
                height: 180,
                child: Image.asset(
                  PImages.logo,
                ),
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: NoEdgeEffectScrollBehavior(),
                child: NotifyingPageView(
                  notifier: _notifier,
                  onChange: (int index) {
                    _notifier.value = index;

                    setState(() {});
                  },
                  children: widget._guidePages.map((page) {
                    return GuidePage(
                      title: page.key,
                      message: page.value.contains('[productname]')
                          ? page.value.replaceAll(
                              '[productname]', remoteConfig.productName)
                          : page.value,
                    );
                  }).toList(),
                ),
              ),
            ),
            PageIndicator(
              pageCount: widget._guidePages.length,
              animation: _notifier,
              dotColor: theme.colorScheme.secondary,
              dotSize: const Size(8.0, 8.0),
              dotSpacing: 12.0,
            ),
            const SizedBox(height: 24),
            Container(
              width: double.maxFinite,
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                bottom: 50.0,
              ),
              child: RoundedOutlineButton(
                context,
                title: Strings.actionLogin.toUpperCase(),
                borderColor: theme.colorScheme.secondary,
                textColor: theme.colorScheme.secondary,
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context)
                      .add(LoginRequestedEvent());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to display single page of the guide
class GuidePage extends StatelessWidget {
  const GuidePage({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).primaryTextTheme.headlineMedium?.copyWith(
                color: PColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 40,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12.0),
        // const SizedBox(height: 32.0),
        Expanded(
          child: ScrollConfiguration(
            behavior: NoEdgeEffectScrollBehavior(),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                // padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .primaryTextTheme
                      .headlineSmall
                      ?.copyWith(
                        height: 1.4,
                        color: PColors.black,
                      ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
