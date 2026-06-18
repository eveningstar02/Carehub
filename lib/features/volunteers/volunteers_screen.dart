import 'package:carehub_app/data/models/volunteer.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class VolunteersScreen extends ConsumerWidget {
  const VolunteersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteers = ref.watch(volunteersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Volunteers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: volunteers.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No volunteers yet'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(volunteersListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final v = list[i];
                return Card(
                  child: ListTile(
                    title: Text(v.name),
                    subtitle: Text(
                      '${v.role ?? 'Volunteer'}\n${v.contactDetails ?? ''}',
                    ),
                    isThreeLine: true,
                    onTap: () => _showActivities(context, ref, v),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, ref, v),
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Volunteer v) async {
    if (v.id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete volunteer'),
        content: Text('Delete ${v.name}? This action can be undone by an admin.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(volunteerRepositoryProvider).softDelete(v.id!);
        ref.invalidate(volunteersListProvider);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Volunteer deleted')));
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  Future<void> _showActivities(
    BuildContext context,
    WidgetRef ref,
    Volunteer v,
  ) async {
    if (v.id == null) return;
    List<VolunteerActivity> activities;
    try {
      activities = await ref
          .read(volunteerRepositoryProvider)
          .activitiesForVolunteer(v.id!);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${v.name} — activities'),
        content: SizedBox(
          width: double.maxFinite,
          child: activities.isEmpty
              ? const Text('No activities logged')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final a in activities)
                      ListTile(
                        title: Text(a.description),
                        subtitle: Text(
                          DateFormat.yMMMd().format(a.activityDate),
                        ),
                      ),
                  ],
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _logActivity(context, ref, v);
            },
            child: const Text('Log activity'),
          ),
        ],
      ),
    );
  }

  Future<void> _logActivity(
    BuildContext context,
    WidgetRef ref,
    Volunteer v,
  ) async {
    if (v.id == null) return;
    final desc = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log activity'),
        content: TextField(
          controller: desc,
          decoration: const InputDecoration(labelText: 'Description'),
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
    if (ok == true && desc.text.isNotEmpty) {
      try {
        await ref.read(volunteerRepositoryProvider).insertActivity(
              VolunteerActivity(
                volunteerId: v.id,
                description: desc.text.trim(),
                activityDate: DateTime.now(),
              ),
            );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e')),
          );
        }
      }
    }
    desc.dispose();
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController();
    final contact = TextEditingController();
    final role = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add volunteer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: contact,
              decoration: const InputDecoration(labelText: 'Contact'),
            ),
            TextField(
              controller: role,
              decoration: const InputDecoration(labelText: 'Role'),
            ),
          ],
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
        await ref.read(volunteerRepositoryProvider).insert(
              Volunteer(
                name: name.text.trim(),
                contactDetails:
                    contact.text.trim().isEmpty ? null : contact.text.trim(),
                role: role.text.trim().isEmpty ? null : role.text.trim(),
              ),
            );
        ref.invalidate(volunteersListProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e')),
          );
        }
      }
    }

    name.dispose();
    contact.dispose();
    role.dispose();
  }
}
