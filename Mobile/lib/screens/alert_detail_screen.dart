import 'package:flutter/material.dart';

import '../models/alert.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/reusable_button.dart';

class AlertDetailScreen extends StatelessWidget {
  const AlertDetailScreen({
    super.key,
    required this.alert,
    required this.onBack,
    required this.onHandleEmergency,
    required this.onStatusChecked,
  });

  final Alert alert;
  final VoidCallback onBack;
  final VoidCallback onHandleEmergency;
  final VoidCallback onStatusChecked;

  @override
  Widget build(BuildContext context) {
    final isPending = alert.status == AlertStatus.pending;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton.outlined(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Text(alert.type, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(formatAlertDate(alert.occurredAt),
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _DetailCard(
                title: 'Severity',
                value: alert.severity.name,
                valueColor: alert.severity == AlertSeverity.high
                    ? AppColors.danger
                    : const Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DetailCard(title: 'Status', value: alert.status.name),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Camera Snapshot',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              _PlaceholderBox(label: 'Image area'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Incident Detail',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(alert.incidentDetail,
                  style:
                      const TextStyle(color: Color(0xFF334155), height: 1.4)),
            ],
          ),
        ),
        if (isPending) ...[
          const SizedBox(height: 12),
          ReusableButton(
            label: 'Status Checked',
            variant: ButtonVariant.ghost,
            onPressed: onStatusChecked,
          ),
          const SizedBox(height: 10),
          ReusableButton(
            label: 'Handle Emergency',
            variant: ButtonVariant.danger,
            onPressed: onHandleEmergency,
          ),
        ],
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.title,
    required this.value,
    this.valueColor,
  });

  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w800, color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.muted, fontSize: 13)),
    );
  }
}
