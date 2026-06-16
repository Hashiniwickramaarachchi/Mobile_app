import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.alertsCount,
    required this.profile,
    required this.lastActivityTime,
    required this.onBack,
    required this.onEmergencyClick,
    required this.onCall1990Click,
    required this.onAlertsClick,
    required this.onOpenProfile,
  });

  final int alertsCount;
  final Profile profile;
  final DateTime? lastActivityTime;
  final VoidCallback onBack;
  final VoidCallback onEmergencyClick;
  final VoidCallback onCall1990Click;
  final VoidCallback onAlertsClick;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getGreetingMessage(),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('SafeGuard Monitor',
                      style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            IconButton.outlined(
              onPressed: onOpenProfile,
              icon: const Icon(Icons.person_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.elderlyName,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Age: ${profile.age}'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _InfoCard(
          color: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFF99E7C1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Safe', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                'Last activity: ${lastActivityTime == null ? '' : formatOnlyTime(lastActivityTime!)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                label: 'Emergency',
                icon: Icons.emergency_rounded,
                color: AppColors.danger,
                onTap: onEmergencyClick,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                label: 'Call 1990',
                icon: Icons.call_rounded,
                color: AppColors.text,
                onTap: onCall1990Click,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _QuickAction(
                label: 'Alerts ($alertsCount)',
                icon: Icons.notifications_rounded,
                color: const Color(0xFFD97706),
                onTap: onAlertsClick,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Live Camera',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              SizedBox(height: 10),
              _CameraPlaceholder(label: 'Camera preview placeholder'),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 19),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.child,
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
      ),
      child: Text(label,
          style: const TextStyle(color: AppColors.muted, fontSize: 13)),
    );
  }
}
