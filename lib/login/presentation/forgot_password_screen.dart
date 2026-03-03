import 'package:flutter/material.dart';
import 'package:pcrypt/util/strings.dart';

/// Screen for resetting password
class ForgotPasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.forgotPasswordTitle),
      ),
      body: const Center(
        child: Text('Not yet implemented'), //TODO implement
      ),
    );
  }
}
