import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pcrypt/model/location.dart';
import 'package:pcrypt/util/location_service.dart';
import 'package:pcrypt/util/strings.dart';
import 'package:pcrypt/web/server_adapter.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Screen for viewing locations on map
class LocationViewerScreen extends StatefulWidget {
  const LocationViewerScreen({
    required this.title,
    required this.locations,
  });

  final String title;
  final List<Location> locations;

  @override
  State createState() => _LocationViewerScreenState();
}

class _LocationViewerScreenState extends State<LocationViewerScreen> {
  _LocationViewerScreenState();

  String? _url;
  bool _isLoading = true;
  late final WebViewController _controller;



  @override
  void initState() {
    super.initState();
    _setUpWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
      ),
      body: Stack(
        children: <Widget>[
          if (_url != null)
            // WebView(
            //   initialUrl: _url,
            //   javascriptMode: JavascriptMode.unrestricted,
            //   onPageFinished: (_) {
            //     setState(() {
            //       _isLoading = false;
            //     });
            //   },
            // ),
            WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> _setUpWebView() async {
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);
    await _generateUrl();
    // controller = WebViewController()
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(_url!));

    _controller = controller;
  }

  Future<void> _generateUrl() async {
    Location? location;
    String? message;
    await LocationService.get.determineCurrentLocation(
      onSuccess: (l) => location = l,
      onFailure: (msg) {
        location = null;
        message = msg;
      },
    );
    if (location == null && message != null) {
      _isLoading = false;
      _showLocationPermissionDeniedDialog(message);
      setState(() {});
      return;
    }
    _url = await ServerAdapter.get
        .getLocationViewerUrl(widget.locations, currentLocation: location);
    setState(() {});
  }

  void _showLocationPermissionDeniedDialog(String? message) {
    if (Platform.isAndroid) {
      showDialog<void>(
        context: context,
        builder: (_) => WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text(Strings.loginPasswordManagerTitle),
            content: Text(message ?? ''),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context)
                  ..pop()
                  ..pop(),
                child: Text(Strings.actionOk),
              ),
            ],
          ),
        ),
      );
    } else if (Platform.isIOS) {
      //Navigator.of(context).pop();
      showCupertinoModalPopup<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Pcrypt'),
          content: Text(message ?? ''),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context)
                ..pop()
                ..pop(),
              child: Text(Strings.actionOk),
            ),
          ],
        ),
      );
    }
  }
}
