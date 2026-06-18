import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/services/qr_lookup_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Full-screen camera scanner. Returns resolved [CareHubQrPayload] on success.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({
    super.key,
    this.acceptTypes,
    this.title = 'Scan CareHub QR',
  });

  final Set<CareHubQrType>? acceptTypes;
  final String title;

  static Future<CareHubQrPayload?> open(
    BuildContext context, {
    Set<CareHubQrType>? acceptTypes,
    String title = 'Scan CareHub QR',
  }) {
    return Navigator.of(context).push<CareHubQrPayload>(
      MaterialPageRoute(
        builder: (_) => QrScanScreen(acceptTypes: acceptTypes, title: title),
      ),
    );
  }

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _lookup = QrLookupService();
  final _controller = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final parsed = CareHubQrPayload.decode(raw);
    if (parsed == null) {
      _showError('Not a valid CareHub QR code');
      return;
    }

    if (widget.acceptTypes != null &&
        !widget.acceptTypes!.contains(parsed.type)) {
      _showError(
        'Expected: ${widget.acceptTypes!.map((e) => e.name).join(', ')}',
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final resolved = await _lookup.resolvePayload(parsed);
      if (!mounted) return;
      Navigator.of(context).pop(resolved ?? parsed);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_processing)
            const ColoredBox(
              color: Colors.black45,
              child: Center(child: CircularProgressIndicator()),
            ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Point at a CareHub label on inventory, schools, or volunteers.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
