import 'package:equatable/equatable.dart';

abstract class TwoFAEvents extends Equatable {
  const TwoFAEvents();

  @override
  List<Object?> get props => [];
}

class Register2FaAccount extends TwoFAEvents {}

class Activate2FA extends TwoFAEvents {}

class LoginWith2FA extends TwoFAEvents {}

// class SignInWithAnotherDevice extends TwoFAEvents {}

class ResetDeviceDetectedProperty extends TwoFAEvents {}

class DispatchErrorMessage extends TwoFAEvents {
  const DispatchErrorMessage(this.message);

  final String message;
}

class CancelLoginRequest extends TwoFAEvents {}

class BlockDevice extends TwoFAEvents {}

class ScanQRCode extends TwoFAEvents {
  const ScanQRCode(this.payload);

  final String payload;
}
