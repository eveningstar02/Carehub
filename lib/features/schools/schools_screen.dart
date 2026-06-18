import 'package:carehub_app/core/qr/carehub_qr.dart';
import 'package:carehub_app/data/models/school.dart';
import 'package:carehub_app/features/qr/qr_label_sheet.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SchoolsScreen extends ConsumerWidget {
  const SchoolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(schoolsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schools & communities')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSchool(context, ref),
        child: const Icon(Icons.add),
      ),
      body: schools.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('Add schools you serve'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(schoolsListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final s = list[i];
                return Card(
                  child: ListTile(
                    title: Text(s.name),
                    subtitle: Text(
                      '${s.location ?? 'No location'}\n'
                      'Girls served: ${s.girlsServed} · Contact: ${s.contactPerson ?? '—'}',
                    ),
                    isThreeLine: true,
                    trailing: s.id == null
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.qr_code),
                            onPressed: () => showCareHubQrLabel(
                              context,
                              CareHubQrPayload.school(
                                id: s.id!,
                                name: s.name,
                                location: s.location,
                                contactPerson: s.contactPerson,
                              ),
                            ),
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

  Future<void> _addSchool(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final location = TextEditingController();
    final contact = TextEditingController();
    final girls = TextEditingController(text: '0');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add school'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'School name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: location,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contact,
                decoration: const InputDecoration(labelText: 'Contact person'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: girls,
                decoration: const InputDecoration(
                  labelText: 'Number of girls served',
                ),
                keyboardType: TextInputType.number,
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
    );

    if (ok == true && name.text.isNotEmpty) {
      try {
        final school = await ref
            .read(schoolRepositoryProvider)
            .insert(
              School(
                name: name.text.trim(),
                location: location.text.trim().isEmpty
                    ? null
                    : location.text.trim(),
                contactPerson: contact.text.trim().isEmpty
                    ? null
                    : contact.text.trim(),
                girlsServed: int.tryParse(girls.text) ?? 0,
              ),
            );
        ref.invalidate(schoolsListProvider);
        ref.invalidate(impactMetricsProvider);
        if (context.mounted && school.id != null) {
          showCareHubQrLabel(
            context,
            CareHubQrPayload.school(
              id: school.id!,
              name: school.name,
              location: school.location,
              contactPerson: school.contactPerson,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
        }
      }
    }

    name.dispose();
    location.dispose();
    contact.dispose();
    girls.dispose();
  }
}
