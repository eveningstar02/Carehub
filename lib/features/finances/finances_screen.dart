import 'package:carehub_app/core/enums/app_enums.dart';
import 'package:carehub_app/data/models/financial_record.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class FinancesScreen extends ConsumerWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(financialListProvider);
    final currency = NumberFormat.simpleCurrency();
    final fmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('Financial records')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context, ref),
        child: const Icon(Icons.add),
      ),
      body: recordsAsync.when(
        data: (records) {
          var balance = 0.0;
          for (final r in records) {
            switch (r.recordType) {
              case FinancialType.monetaryDonation:
                balance += r.amount;
              case FinancialType.purchase:
              case FinancialType.expense:
                balance -= r.amount;
            }
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const Icon(Icons.account_balance),
                  title: const Text('Current balance'),
                  trailing: Text(
                    currency.format(balance),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? const Center(child: Text('No financial records'))
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(financialListProvider),
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (_, i) {
                            final r = records[i];
                            final isIncome =
                                r.recordType == FinancialType.monetaryDonation;
                            return ListTile(
                              leading: Icon(
                                isIncome
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                              title: Text(r.description ?? r.recordType.name),
                              subtitle: Text(fmt.format(r.recordDate)),
                              trailing: Text(
                                '${isIncome ? '+' : '-'}${currency.format(r.amount)}',
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final amount = TextEditingController();
    final desc = TextEditingController();
    var type = FinancialType.monetaryDonation;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Add financial record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<FinancialType>(
                value: type,
                isExpanded: true,
                items: FinancialType.values
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) => setLocal(() => type = v!),
              ),
              TextField(
                controller: amount,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Description'),
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
      ),
    );

    if (ok == true) {
      try {
        await ref.read(financialRepositoryProvider).insert(
              FinancialRecord(
                recordType: type,
                amount: double.tryParse(amount.text) ?? 0,
                description: desc.text.trim().isEmpty ? null : desc.text.trim(),
                recordDate: DateTime.now(),
              ),
            );
        ref.invalidate(financialListProvider);
        ref.invalidate(impactMetricsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save: $e')),
          );
        }
      }
    }

    amount.dispose();
    desc.dispose();
  }
}
