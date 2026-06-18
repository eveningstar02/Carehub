import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/models/donation_record.dart';
import 'package:carehub_app/data/services/qr_lookup_service.dart';
import 'package:carehub_app/features/qr/qr_scan_fab.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DonationsScreen extends ConsumerWidget {
  const DonationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donations = ref.watch(donationsListProvider);
    final fmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: donations.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No donations recorded'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(donationsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final d = list[i];
                return Card(
                  child: ListTile(
                    title: Text(d.donorName),
                    subtitle: Text(
                      '${fmt.format(d.donationDate)} · ${d.donationType.name}\n'
                      'Qty: ${d.quantity}${d.notes != null ? '\n${d.notes}' : ''}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final donor = TextEditingController();
    final contact = TextEditingController();
    final qty = TextEditingController(text: '0');
    final notes = TextEditingController();
    var type = DonationType.pads;
    String? inventoryItemId;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Record donation')),
              QrScanIconButton(
                acceptTypes: const {
                  CareHubQrType.inventory,
                  CareHubQrType.donation,
                },
                onScanned: (p) {
                  final fill = DonationScanFill.fromPayload(p);
                  if (fill == null) return;
                  setLocal(() {
                    if (fill.donorName != null) donor.text = fill.donorName!;
                    if (fill.quantity != null) qty.text = '${fill.quantity}';
                    if (fill.notes != null) notes.text = fill.notes!;
                    inventoryItemId = fill.inventoryItemId;
                  });
                },
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: donor,
                  decoration: const InputDecoration(
                    labelText: 'Donor / organization',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contact,
                  decoration: const InputDecoration(labelText: 'Contact'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: qty,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButton<DonationType>(
                  value: type,
                  isExpanded: true,
                  items: DonationType.values
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (v) => setLocal(() => type = v!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
              ],
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

    if (ok == true && donor.text.isNotEmpty) {
      try {
        await ref
            .read(donationRepositoryProvider)
            .insert(
              DonationRecord(
                donorName: donor.text.trim(),
                contactDetails: contact.text.trim().isEmpty
                    ? null
                    : contact.text.trim(),
                donationDate: DateTime.now(),
                quantity: int.tryParse(qty.text) ?? 0,
                donationType: type,
                notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                inventoryItemId: inventoryItemId,
              ),
            );
        ref.invalidate(donationsListProvider);
        ref.invalidate(impactMetricsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
        }
      }
    }

    donor.dispose();
    contact.dispose();
    qty.dispose();
    notes.dispose();
  }
}
