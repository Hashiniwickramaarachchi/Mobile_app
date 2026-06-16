import 'package:flutter/material.dart';

import '../utils/constants.dart';

enum AppTab { home, alerts, settings }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.tab,
    required this.onChange,
  });

  final AppTab tab;
  final ValueChanged<AppTab> onChange;

  @override
  Widget build(BuildContext context) {
    final items = [
      (AppTab.home, 'Home', Icons.home_rounded),
      (AppTab.alerts, 'Alerts', Icons.notifications_rounded),
      (AppTab.settings, 'Settings', Icons.settings_rounded),
    ];

    return Container(
      height: AppSpacing.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: InkWell(
                onTap: () => onChange(item.$1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.$3,
                      color:
                          tab == item.$1 ? AppColors.danger : AppColors.muted,
                      size: 21,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color:
                            tab == item.$1 ? AppColors.danger : AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
