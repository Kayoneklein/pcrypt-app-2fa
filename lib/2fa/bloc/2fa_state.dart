import 'package:equatable/equatable.dart';
import 'package:pcrypt/constants/preferences.dart';
import 'package:pcrypt/model/security_data.dart';

class TwoFAState extends Equatable {
  const TwoFAState({
    required this.isLoading,
    required this.newDeviceDetected,
    required this.email,
    required this.errorMessage,
    required this.successMessage,
    this.securityUser,
    this.twoFa,
  });

  final bool isLoading;
  final bool newDeviceDetected;
  final String email;
  final String errorMessage;
  final String successMessage;
  final SecurityUser? securityUser;
  final TwoFAModel? twoFa;

  TwoFAState copyWith({
    bool? isLoading,
    bool? newDeviceDetected,
    String? email,
    String? errorMessage,
    String? successMessage,
    SecurityUser? securityUser,
    TwoFAModel? twoFa,
  }) {
    return TwoFAState(
      isLoading: isLoading ?? this.isLoading,
      newDeviceDetected: newDeviceDetected ?? this.newDeviceDetected,
      email: email ?? this.email,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      securityUser: securityUser ?? this.securityUser,
      twoFa: twoFa ?? this.twoFa,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        securityUser,
        twoFa,
        successMessage,
        errorMessage,
        newDeviceDetected,
        email,
      ];
}

class Initial2FAState extends TwoFAState {
  Initial2FAState()
      : super(
          isLoading: false,
          newDeviceDetected: false,
          email: '',
          errorMessage: '',
          successMessage: '',
        );
}
