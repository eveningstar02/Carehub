import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Shows a printable/shareable QR for a record.
void showCareHubQrLabel(BuildContext context, CareHubQrPayload payload) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'QR label — ${payload.type.name}',
            style: Theme.of(ctx).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          QrImageView(
            data: payload.encode(),
            version: QrVersions.auto,
            size: 220,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            'Scan to auto-fill ${payload.type.name} details',
            style: Theme.of(ctx).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          SelectableText(
            payload.encode(),
            style: Theme.of(ctx).textTheme.labelSmall,
            maxLines: 3,
          ),
        ],
      ),
    ),
  );
}
