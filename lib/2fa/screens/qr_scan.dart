part of '../index.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'This device is about to login to your account. Please verify the device by scanning the QR code.',
              style: theme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              'Open your primary device or login to your web portal to scan the QR',
              style: theme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // Text(
            //   'https://pcrypt-secure.onrender.com/token',
            //   style: theme.bodyMedium?.copyWith(
            //     fontSize: 12,
            //     fontWeight: FontWeight.bold,
            //   ),
            // ),
            const SizedBox(height: 30),
            BlocConsumer<TwoFABloc, TwoFAState>(
              listener: (ctx, state) {
                // if (state.newDeviceDetected == false) {
                //   Navigator.pop(context);
                // }
              },
              builder: (ctx, state) {
                return Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: MobileScanner(
                        onDetect: (result) {
                          if (state.isLoading == false) {
                            // print(result.barcodes.first.rawValue);
                            final payload =
                                result.barcodes.first.rawValue ?? '';

                            BlocProvider.of<TwoFABloc>(context)
                                .add(ScanQRCode(payload));
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (state.errorMessage.isNotEmpty) Text(state.errorMessage),
                  ],
                );
              },
            ),
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
