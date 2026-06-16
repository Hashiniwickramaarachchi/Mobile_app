import 'package:flutter/material.dart';

import '../utils/constants.dart';

enum ButtonVariant { primary, danger, warning, ghost }

class ReusableButton extends StatelessWidget {
  const ReusableButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = _colors();
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colors.$1,
          foregroundColor: colors.$2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: child,
      ),
    );
  }

  (Color, Color) _colors() {
    switch (variant) {
      case ButtonVariant.primary:
        return (AppColors.primary, Colors.white);
      case ButtonVariant.danger:
        return (AppColors.danger, Colors.white);
      case ButtonVariant.warning:
        return (AppColors.warning, Colors.white);
      case ButtonVariant.ghost:
        return (const Color(0xFFF3F4F6), AppColors.text);
    }
  }
}
