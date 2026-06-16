import 'package:flutter/material.dart';

import '../models/alert.dart';
import '../utils/constants.dart';
import '../widgets/alert_card.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({
    super.key,
    required this.alerts,
    required this.filter,
    required this.onBack,
    required this.onFilterChange,
    required this.onOpenAlert,
  });

  final List<Alert> alerts;
  final AlertStatus? filter;
  final VoidCallback onBack;
  final ValueChanged<AlertStatus?> onFilterChange;
  final ValueChanged<int> onOpenAlert;

  @override
  Widget build(BuildContext context) {
    final filteredAlerts = filter == null
        ? alerts
        : alerts.where((alert) => alert.status == filter).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.screenPadding,
        AppSpacing.bottomNavHeight + 20,
      ),
      children: [
        Row(
          children: [
            IconButton.outlined(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Alerts',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(
                label: 'All',
                active: filter == null,
                onTap: () => onFilterChange(null)),
            _FilterChip(
              label: 'Pending',
              active: filter == AlertStatus.pending,
              onTap: () => onFilterChange(AlertStatus.pending),
            ),
            _FilterChip(
              label: 'Checked',
              active: filter == AlertStatus.checked,
              onTap: () => onFilterChange(AlertStatus.checked),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (final alert in filteredAlerts) ...[
          AlertCard(alert: alert, onTap: () => onOpenAlert(alert.id)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: active ? const Color(0xFFE0F2FE) : AppColors.surface,
        foregroundColor:
            active ? const Color(0xFF0C4A6E) : const Color(0xFF475569),
        side: BorderSide(
            color: active ? AppColors.primary : const Color(0xFFD1D5DB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        visualDensity: VisualDensity.compact,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
