import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/models/pad_inventory_item.dart';
import 'package:carehub_app/data/services/qr_lookup_service.dart';
import 'package:carehub_app/features/qr/qr_label_sheet.dart';
import 'package:carehub_app/features/qr/qr_scan_fab.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inventoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pad inventory'),
        actions: [
          QrScanIconButton(
            acceptTypes: const {CareHubQrType.inventory},
            tooltip: 'Scan inventory QR',
            onScanned: (p) => _openForm(
              context,
              ref,
              scanFill: InventoryScanFill.fromPayload(p),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context, ref),
        child: const Icon(Icons.add),
      ),
      body: items.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No inventory items yet'));
          }
          final dateFmt = DateFormat.yMMMd();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(inventoryListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final item = list[i];
                return Card(
                  child: ListTile(
                    title: Text('${item.brand} — ${item.type}'),
                    subtitle: Text(
                      '${item.absorbencyLevel} · ${item.padCategory.name}\n'
                      'Stock: ${item.quantityInStock} packets'
                      '${item.expiryDate != null ? ' · Exp: ${dateFmt.format(item.expiryDate!)}' : ''}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.qr_code),
                          tooltip: 'Show QR label',
                          onPressed: () {
                            final repo = ref.read(inventoryRepositoryProvider);
                            showCareHubQrLabel(context, repo.qrPayloadFor(item));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _openForm(context, ref, item: item),
                        ),
                      ],
                    ),
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

  Future<void> _openForm(
    BuildContext context,
    WidgetRef ref, {
    PadInventoryItem? item,
    InventoryScanFill? scanFill,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _InventoryForm(
        item: item,
        scanFill: scanFill,
        onSave: (saved) async {
          final repo = ref.read(inventoryRepositoryProvider);
          final stored = await repo.save(saved);
          ref.invalidate(inventoryListProvider);
          ref.invalidate(stockAlertsProvider);
          ref.invalidate(impactMetricsProvider);
          if (ctx.mounted) {
            Navigator.pop(ctx);
            showCareHubQrLabel(context, repo.qrPayloadFor(stored));
          }
        },
      ),
    );
  }
}

class _InventoryForm extends StatefulWidget {
  const _InventoryForm({this.item, this.scanFill, required this.onSave});
  final PadInventoryItem? item;
  final InventoryScanFill? scanFill;
  final Future<void> Function(PadInventoryItem) onSave;

  @override
  State<_InventoryForm> createState() => _InventoryFormState();
}

class _InventoryFormState extends State<_InventoryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brand;
  late final TextEditingController _type;
  late final TextEditingController _absorbency;
  late final TextEditingController _color;
  late final TextEditingController _batch;
  late final TextEditingController _location;
  late final TextEditingController _qty;
  late final TextEditingController _packetSize;
  late final TextEditingController _cost;
  late PadCategory _category;
  DateTime? _expiry;
  String? _existingId;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final scan = widget.scanFill;
    _existingId = item?.id ?? scan?.id;
    _brand = TextEditingController(text: item?.brand ?? scan?.brand);
    _type = TextEditingController(text: item?.type ?? scan?.type);
    _absorbency = TextEditingController(
      text: item?.absorbencyLevel ?? scan?.absorbencyLevel,
    );
    _color = TextEditingController(text: item?.color ?? scan?.color);
    _batch = TextEditingController(text: item?.batchNumber ?? scan?.batchNumber);
    _location = TextEditingController(
      text: item?.storageLocation ?? scan?.storageLocation,
    );
    _qty = TextEditingController(
      text: '${item?.quantityInStock ?? scan?.quantityInStock ?? 0}',
    );
    _packetSize = TextEditingController(
      text: '${item?.packetSize ?? scan?.packetSize ?? 1}',
    );
    _cost = TextEditingController(
      text: item?.costPerPacket?.toString() ??
          scan?.costPerPacket?.toString() ??
          '',
    );
    _category =
        item?.padCategory ?? scan?.padCategory ?? PadCategory.disposable;
    _expiry = item?.expiryDate ?? scan?.expiryDate;
  }

  @override
  void dispose() {
    _brand.dispose();
    _type.dispose();
    _absorbency.dispose();
    _color.dispose();
    _batch.dispose();
    _location.dispose();
    _qty.dispose();
    _packetSize.dispose();
    _cost.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item == null ? 'Add inventory' : 'Edit inventory',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  QrScanIconButton(
                    acceptTypes: const {CareHubQrType.inventory},
                    onScanned: (p) {
                      final fill = InventoryScanFill.fromPayload(p);
                      setState(() {
                        _existingId = fill.id;
                        if (fill.brand != null) _brand.text = fill.brand!;
                        if (fill.type != null) _type.text = fill.type!;
                        if (fill.absorbencyLevel != null) {
                          _absorbency.text = fill.absorbencyLevel!;
                        }
                        if (fill.color != null) _color.text = fill.color!;
                        if (fill.batchNumber != null) {
                          _batch.text = fill.batchNumber!;
                        }
                        if (fill.storageLocation != null) {
                          _location.text = fill.storageLocation!;
                        }
                        if (fill.packetSize != null) {
                          _packetSize.text = '${fill.packetSize}';
                        }
                        if (fill.quantityInStock != null) {
                          _qty.text = '${fill.quantityInStock}';
                        }
                        if (fill.costPerPacket != null) {
                          _cost.text = '${fill.costPerPacket}';
                        }
                        if (fill.padCategory != null) {
                          _category = fill.padCategory!;
                        }
                        if (fill.expiryDate != null) {
                          _expiry = fill.expiryDate;
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brand,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _absorbency,
                decoration:
                    const InputDecoration(labelText: 'Absorbency level'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<PadCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: PadCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              TextFormField(
                controller: _color,
                decoration: const InputDecoration(labelText: 'Color'),
              ),
              TextFormField(
                controller: _packetSize,
                decoration: const InputDecoration(labelText: 'Packet size'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _qty,
                decoration:
                    const InputDecoration(labelText: 'Quantity in stock'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _batch,
                decoration: const InputDecoration(labelText: 'Batch number'),
              ),
              ListTile(
                title: Text(
                  _expiry == null
                      ? 'Expiry date (optional)'
                      : 'Expiry: ${DateFormat.yMMMd().format(_expiry!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                    initialDate: _expiry ?? DateTime.now(),
                  );
                  if (picked != null) setState(() => _expiry = picked);
                },
              ),
              TextFormField(
                controller: _location,
                decoration:
                    const InputDecoration(labelText: 'Storage location'),
              ),
              TextFormField(
                controller: _cost,
                decoration:
                    const InputDecoration(labelText: 'Cost per packet'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final item = PadInventoryItem(
                    id: _existingId,
                    brand: _brand.text.trim(),
                    type: _type.text.trim(),
                    absorbencyLevel: _absorbency.text.trim(),
                    padCategory: _category,
                    color: _color.text.trim().isEmpty
                        ? null
                        : _color.text.trim(),
                    packetSize: int.tryParse(_packetSize.text) ?? 1,
                    quantityInStock: int.tryParse(_qty.text) ?? 0,
                    batchNumber: _batch.text.trim().isEmpty
                        ? null
                        : _batch.text.trim(),
                    expiryDate: _expiry,
                    storageLocation: _location.text.trim().isEmpty
                        ? null
                        : _location.text.trim(),
                    costPerPacket: double.tryParse(_cost.text),
                  );
                  await widget.onSave(item);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
