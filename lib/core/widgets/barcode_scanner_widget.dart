import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_datawedge/flutter_datawedge.dart';
import 'package:flutter_datawedge/models/scan_result.dart';
import '../constants/app_colors.dart';

/// Hybrid barcode scanner that supports both:
/// 1. Camera-based scanning (for regular mobile devices)
/// 2. Zebra DataWedge hardware scanning (for Zebra scanner guns)
class BarcodeScannerWidget extends StatefulWidget {
  final Function(String) onScanned;
  final String? title;

  const BarcodeScannerWidget({super.key, required this.onScanned, this.title});

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController? _cameraController;
  FlutterDataWedge? _dataWedge;
  StreamSubscription<ScanResult>? _scanSubscription;

  bool _isZebraDevice = false;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing scanner...';

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    if (!Platform.isAndroid) {
      // iOS or other platforms - use camera only
      _initializeCameraScanner();
      return;
    }

    try {
      // Try to initialize DataWedge (for Zebra devices)
      _dataWedge = FlutterDataWedge(profileName: 'PutawayApp');
      await _dataWedge!.initialize();

      // Zebra device detected - setup DataWedge
      _isZebraDevice = true;
      await _setupDataWedge();
    } catch (e) {
      // DataWedge not available - use camera scanner
      _initializeCameraScanner();
    }
  }

  Future<void> _setupDataWedge() async {
    try {
      // Listen to scan results
      _scanSubscription = _dataWedge!.onScanResult.listen(
        (ScanResult result) {
          if (result.data.isNotEmpty) {
            widget.onScanned(result.data);
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _statusMessage = 'Scanner error: $error';
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isInitializing = false;
          _statusMessage = 'Press trigger to scan';
        });
      }
    } catch (e) {
      // If DataWedge setup fails, fall back to camera
      _initializeCameraScanner();
    }
  }

  void _initializeCameraScanner() {
    _cameraController = MobileScannerController();
    setState(() {
      _isZebraDevice = false;
      _isInitializing = false;
      _statusMessage = 'Point camera at barcode';
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _onCameraDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _cameraController?.stop();
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
        backgroundColor: AppColors.primary,
        actions: [
          if (_isZebraDevice)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Zebra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isInitializing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(_statusMessage, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (_isZebraDevice) {
      return _buildZebraScannerUI();
    } else {
      return _buildCameraScannerUI();
    }
  }

  Widget _buildZebraScannerUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withValues(alpha: 0.1), Colors.white],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.qr_code_scanner,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Zebra Scanner Ready',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Use the physical trigger button on your Zebra device to scan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraScannerUI() {
    if (_cameraController == null) {
      return const Center(child: Text('Camera not available'));
    }

    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController!,
          onDetect: _onCameraDetect,
        ),
        Positioned(
          bottom: 32,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
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
