part of '../index.dart';

class QrCodeDisplay extends StatelessWidget {
  const QrCodeDisplay({super.key, required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: QrImageView(
                data: payload,
                version: QrVersions.auto,
                size: 180,
                gapless: false,
                // optional: embeddedImage: AssetImage('assets/logo.png'),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scan this QR code to verify the new device',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const ActionButtonsScreen(),
          ],
        ),
      ),
    );
  }
}
