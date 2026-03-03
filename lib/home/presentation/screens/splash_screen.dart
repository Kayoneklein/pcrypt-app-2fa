import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pcrypt/config/configuration_bloc.dart';
import 'package:pcrypt/constants/assets.dart';
import 'package:pcrypt/constants/global_variables.dart';
import 'package:pcrypt/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

///Screen for displaying splash screen
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final remoteConfig =
        BlocProvider.of<ConfigurationBloc>(context).state.configuration;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: <Widget>[
                Container(
                  width: 96.0,
                  height: 96.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                      image: AssetImage(PImages.logo),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: AutoSizeText(
                          // remoteConfig.productName.isNotEmpty
                          //     ? remoteConfig.productName
                          //     : appName,
                          appName,
                          maxLines: 2,
                          maxFontSize: 28,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.white,
                            inherit: false,
                            fontSize: 28.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        child: LinearProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                              Theme.of(context).primaryIconTheme.color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
