import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../constants/app_colors.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onScanned;
  final String? title;

  const BarcodeScannerWidget({super.key, required this.onScanned, this.title});

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        controller.stop();
        widget.onScanned(barcode.rawValue!);
        Navigator.of(context).pop();
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Scan Barcode'),
        actions: [
          // IconButton(
          //   icon: ValueListenableBuilder(
          //     valueListenable: controller.torchState,
          //     builder: (context, state, child) {
          //       switch (state) {
          //         case TorchState.off:
          //           return const Icon(Icons.flash_off, color: Colors.white);
          //         case TorchState.on:
          //           return const Icon(Icons.flash_on, color: Colors.amber);
          //       }
          //     },
          //   ),
          //   onPressed: () => controller.toggleTorch(),
          // ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Point camera at barcode',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String?> showBarcodeScanner(
  BuildContext context, {
  String? title,
}) async {
  String? result;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => BarcodeScannerWidget(
        title: title,
        onScanned: (value) {
          result = value;
        },
      ),
    ),
  );
  return result;
}
