import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScanner extends StatefulWidget {
  final String title;
  final String description;
  final Function(String?) onQRCodeScanned;

  const QRScanner({
    super.key,
    required this.title,
    required this.description,
    required this.onQRCodeScanned,
  });

  @override
  QRScannerState createState() => QRScannerState();
}

class QRScannerState extends State<QRScanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.0,
            ),
          ),
          Text(
            widget.description,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.noDuplicates,
              ),
              fit: BoxFit.contain,
              scanWindow: Rect.fromPoints(
                const Offset(50, 50),
                const Offset(250, 250),
              ),
              onDetect: _handleScanResult,
            ),
          ),
        ],
      ),
    );
  }

  void _handleScanResult(capture) {
    final List<Barcode> barcodes = capture.barcodes;
    final barcode = barcodes[0].rawValue;
    debugPrint('Barcode found! $barcode');
    widget.onQRCodeScanned(barcode);

    Navigator.of(context).pop();
  }
}
