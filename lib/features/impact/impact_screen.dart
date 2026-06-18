import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ImpactScreen extends ConsumerWidget {
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(impactMetricsProvider);
    final alerts = ref.watch(stockAlertsProvider);
    final currency = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('CareHub Impact')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(impactMetricsProvider);
          ref.invalidate(stockAlertsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            metrics.when(
              data: (m) => Column(
                children: [
                  _MetricGrid(
                    items: [
                      _MetricTile(
                        label: 'Pads donated',
                        value: '${m.totalPadsDonated}',
                        icon: Icons.favorite,
                      ),
                      _MetricTile(
                        label: 'Pads distributed',
                        value: '${m.totalPadsDistributed}',
                        icon: Icons.check_circle_outline,
                      ),
                      _MetricTile(
                        label: 'Girls supported',
                        value: '${m.girlsSupported}',
                        icon: Icons.face_retouching_natural,
                      ),
                      _MetricTile(
                        label: 'Schools',
                        value: '${m.schoolsReached}',
                        icon: Icons.school,
                      ),
                      _MetricTile(
                        label: 'Communities',
                        value: '${m.communitiesServed}',
                        icon: Icons.location_city,
                      ),
                      _MetricTile(
                        label: 'Fund balance',
                        value: currency.format(m.monetaryBalance),
                        icon: Icons.payments,
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),
            Text(
              'Stock alerts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            alerts.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Card(
                    child: ListTile(
                      leading: Icon(Icons.check, color: Colors.green),
                      title: Text('No stock or expiry alerts'),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final a in list)
                      Card(
                        child: ListTile(
                          leading: Icon(
                            a.severity.name == 'critical'
                                ? Icons.error
                                : Icons.warning_amber,
                            color: a.severity.name == 'critical'
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text(a.message),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});
  final List<_MetricTile> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: items,
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: scheme.primary),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
