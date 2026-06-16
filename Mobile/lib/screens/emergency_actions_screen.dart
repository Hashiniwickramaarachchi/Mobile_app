import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/reusable_button.dart';

class EmergencyActionsScreen extends StatelessWidget {
  const EmergencyActionsScreen({
    super.key,
    required this.emergencyContactNumber,
    required this.onBack,
    required this.onAction,
  });

  final String emergencyContactNumber;
  final VoidCallback onBack;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
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
        Text('Emergency Actions',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 18),
        ReusableButton(
          label: 'Call Emergency Contact',
          icon: Icons.call_rounded,
          onPressed: emergencyContactNumber.isEmpty
              ? null
              : () => onAction(emergencyContactNumber),
        ),
        const SizedBox(height: 10),
        ReusableButton(
          label: 'Call Ambulance',
          icon: Icons.local_hospital_rounded,
          variant: ButtonVariant.danger,
          onPressed: () => onAction('1990'),
        ),
        const SizedBox(height: 10),
        ReusableButton(
          label: 'Call 1990 Hotline',
          icon: Icons.support_agent_rounded,
          variant: ButtonVariant.warning,
          onPressed: () => onAction('1990'),
        ),
      ],
    );
  }
}
