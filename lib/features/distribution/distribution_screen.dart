import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/models/distribution_record.dart';
import 'package:carehub_app/data/services/qr_lookup_service.dart';
import 'package:carehub_app/features/qr/qr_scan_fab.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DistributionScreen extends ConsumerWidget {
  const DistributionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distributions = ref.watch(distributionsListProvider);
    final fmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution'),
        actions: [
          QrScanIconButton(
            tooltip: 'Scan & record distribution',
            onScanned: (_) => _add(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: distributions.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No distributions yet'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(distributionsListProvider),
            child: Column(
              children: [
                FutureBuilder<int>(
                  future: ref
                      .read(distributionRepositoryProvider)
                      .totalQuantity(),
                  builder: (ctx, snap) {
                    final total = snap.data ?? 0;
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total distributed: $total',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (snap.connectionState == ConnectionState.waiting)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final d = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(d.recipientName ?? d.recipientType.name),
                          subtitle: Text(
                            '${fmt.format(d.distributionDate)} · Qty ${d.quantity}\n'
                            '${d.brand ?? ''} ${d.location ?? ''}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: 'Delete',
                            onPressed: () => _confirmDelete(context, ref, d),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    DistributionRecord d,
  ) async {
    if (d.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete distribution'),
        content: Text(
          'Delete distribution for ${d.recipientName ?? d.recipientType.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(distributionRepositoryProvider).softDelete(d.id!);
        ref.invalidate(distributionsListProvider);
        ref.invalidate(impactMetricsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Distribution deleted')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final recipient = TextEditingController();
    final qty = TextEditingController(text: '0');
    final brand = TextEditingController();
    final location = TextEditingController();
    final volunteer = TextEditingController();
    final notes = TextEditingController();
    var recipientType = RecipientType.school;
    String? schoolId;
    String? beneficiaryId;
    String? communityId;
    String? inventoryItemId;
    String? volunteerId;

    void applyScan(CareHubQrPayload payload) {
      final fill = DistributionScanFill.fromPayload(payload);
      if (fill == null) return;
      if (fill.recipientType != null) recipientType = fill.recipientType!;
      if (fill.recipientName != null) recipient.text = fill.recipientName!;
      if (fill.brand != null) brand.text = fill.brand!;
      if (fill.location != null) location.text = fill.location!;
      if (fill.volunteerName != null) volunteer.text = fill.volunteerName!;
      if (fill.quantity != null) qty.text = '${fill.quantity}';
      schoolId = fill.schoolId ?? schoolId;
      beneficiaryId = fill.beneficiaryId ?? beneficiaryId;
      communityId = fill.communityId ?? communityId;
      inventoryItemId = fill.inventoryItemId ?? inventoryItemId;
      volunteerId = fill.volunteerId ?? volunteerId;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Record distribution')),
              QrScanIconButton(onScanned: (p) => setLocal(() => applyScan(p))),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButton<RecipientType>(
                    value: recipientType,
                    isExpanded: true,
                    items: RecipientType.values
                        .map(
                          (t) =>
                              DropdownMenuItem(value: t, child: Text(t.name)),
                        )
                        .toList(),
                    onChanged: (v) => setLocal(() => recipientType = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: recipient,
                    decoration: const InputDecoration(
                      labelText: 'Recipient / school name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qty,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: brand,
                    decoration: const InputDecoration(labelText: 'Brand'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: volunteer,
                    decoration: const InputDecoration(
                      labelText: 'Distributor / volunteer',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: location,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notes,
                    decoration: const InputDecoration(labelText: 'Notes'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (ok == true) {
      try {
        await ref
            .read(distributionRepositoryProvider)
            .insert(
              DistributionRecord(
                distributionDate: DateTime.now(),
                recipientType: recipientType,
                recipientName: recipient.text.trim().isEmpty
                    ? null
                    : recipient.text.trim(),
                schoolId: schoolId,
                beneficiaryId: beneficiaryId,
                communityId: communityId,
                quantity: int.tryParse(qty.text) ?? 0,
                brand: brand.text.trim().isEmpty ? null : brand.text.trim(),
                volunteerId: volunteerId,
                location: location.text.trim().isEmpty
                    ? null
                    : location.text.trim(),
                notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                inventoryItemId: inventoryItemId,
              ),
            );
        ref.invalidate(distributionsListProvider);
        ref.invalidate(impactMetricsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
        }
      }
    }

    for (final c in [recipient, qty, brand, location, volunteer, notes]) {
      c.dispose();
    }
  }
}
