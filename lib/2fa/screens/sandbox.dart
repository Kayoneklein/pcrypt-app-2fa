part of '../index.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    _getDeviceId();
  }

  Future<void> _getDeviceId() async {
    deviceId = await Preferences().deviceId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context).textTheme;

    return BlocConsumer<TwoFABloc, TwoFAState>(
        listener: (context, state) {},
        builder: (_, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('2FA Sandbox'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (state.newDeviceDetected) {
                    BlocProvider.of<TwoFABloc>(context).add(
                      ResetDeviceDetectedProperty(),
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: StreamBuilder<ApiResponse>(
                  stream: HTTPService2FA.get.detectNewDevice(),
                  builder: (_, snapshot) {
                    if (snapshot.data?.status == true) {
                      final Map body = snapshot.data?.body ?? {};
                      final payload = body['payload'] as String?;
                      EncryptData? data;

                      if (payload != null) {
                        final decrypted = Encryption().decrypt(payload);
                        final Map<String, dynamic> json = jsonDecode(decrypted);

                        data = EncryptData.fromJson(json);
                      }
                      // const _deviceId =
                      //     'Encryption().decrypt( Preferences().deviceId ?? '
                      //     ')';
                      final _deviceId = Encryption().decrypt(deviceId);
                      // print('_deviceId');
                      // print(_deviceId);
                      // print(body['new_device_detected'].runtimeType);
                      // print(body['new_device_detected']);
                      // print('data?.deviceId');
                      // print(data?.deviceId);
                      // print('Preferences.pref.deviceId');
                      // print(Preferences.pref.deviceId);

                      if (body['new_device_detected'] == 1 &&
                          data?.deviceId != null &&
                          data?.deviceId?.isNotEmpty == true &&
                          data?.deviceId == _deviceId) {
                        return QrCodeDisplay(payload: payload ?? '');
                      }
                      if (body['new_device_detected'] == 0) {
                        if (state.newDeviceDetected) {
                          Future.delayed(const Duration(seconds: 0), () {
                            BlocProvider.of<TwoFABloc>(context)
                                .add(ResetDeviceDetectedProperty());
                          });
                        }
                      }
                    }
                    if (state.newDeviceDetected) {
                      return const QRScanButton();
                    }
                    return SandboxStage(state: state);
                  }),
            ),
          );
        });
  }
}

class QRScanButton extends StatelessWidget {
  const QRScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Your device changed. You will need to grant permission to continue using the account on this device.',
            style: theme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _ActionBtn(
            text: 'Scan QR code to verify',
            onPressed: () {
              //
              // BlocProvider.of<TwoFABloc>(context).add(
              //   ResetDeviceChangeProperty(),
              // );
              Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                return const QrScanScreen();
              }));
            },
          ),
        ],
      ),
    );
  }
}

class SandboxStage extends StatelessWidget {
  const SandboxStage({super.key, required this.state});

  final TwoFAState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 150),
        _ActionBtn(
          text: 'Register 2fa service on account',
          onPressed: () {
            BlocProvider.of<TwoFABloc>(context).add(Register2FaAccount());
          },
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionBtn(
              text: 'Activate 2fa',
              onPressed: () {
                BlocProvider.of<TwoFABloc>(context).add(Activate2FA());
              },
            ),
            _ActionBtn(
              text: 'Login with 2fa',
              onPressed: () {
                BlocProvider.of<TwoFABloc>(context).add(LoginWith2FA());
              },
            ),
          ],
        ),
        const SizedBox(height: 30),
        // _ActionBtn(
        //   text: 'Sign in with another device',
        //   onPressed: () {
        //     if (state.securityUser?.email == null) {
        //       BlocProvider.of<TwoFABloc>(context).add(
        //         const DispatchErrorMessage('Please login first'),
        //       );
        //       return;
        //     }
        //     BlocProvider.of<TwoFABloc>(context).add(
        //       ResetDeviceChangeProperty(),
        //     );
        //     Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        //       return const QrScanScreen();
        //     }));
        //   },
        // ),
        const SizedBox(height: 30),
        if (state.errorMessage.isNotEmpty)
          Text(
            state.errorMessage,
            textAlign: TextAlign.center,
            style: theme.bodyMedium?.copyWith(
              color: Colors.red,
            ),
          ),
        if (state.successMessage.isNotEmpty)
          Text(
            state.successMessage,
            textAlign: TextAlign.center,
            style: theme.bodyMedium?.copyWith(
              color: Colors.green,
            ),
          ),
        if (state.isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({required this.text, required this.onPressed});

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return TextButton(
      onPressed: () => onPressed(),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
      child: Text(
        text,
        style: theme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
