import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/features/qr/qr_scan_screen.dart';
import 'package:flutter/material.dart';

/// Compact scan action for app bars and forms.
class QrScanIconButton extends StatelessWidget {
  const QrScanIconButton({
    super.key,
    required this.onScanned,
    this.acceptTypes,
    this.tooltip = 'Scan QR',
  });

  final ValueChanged<CareHubQrPayload> onScanned;
  final Set<CareHubQrType>? acceptTypes;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.qr_code_scanner),
      tooltip: tooltip,
      onPressed: () async {
        final payload = await QrScanScreen.open(
          context,
          acceptTypes: acceptTypes,
        );
        if (payload != null && context.mounted) {
          onScanned(payload);
        }
      },
    );
  }
}
