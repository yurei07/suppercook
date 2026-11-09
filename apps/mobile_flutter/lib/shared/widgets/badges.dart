import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_typography.dart';
import '../../core/extensions.dart';

class MatchBadge extends StatelessWidget {
  final int percent;
  final bool compact;

  const MatchBadge({super.key, required this.percent, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final high = percent >= 80;
    final foreground = high ? Colors.black : AppColors.accent;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: high ? AppColors.accent : AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: high ? Colors.transparent : AppColors.accent.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: compact ? 11 : 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            compact ? '$percent%' : '$percent% ${context.l10n.matchLabel}',
            style: TextStyle(
              fontFamily: AppTypography.sans,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const MetaPill({super.key, required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: foreground),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.sans,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: foreground,
          ),
        ),
      ],
    );
  }
}

class AppStatusDot extends StatelessWidget {
  final Color color;

  const AppStatusDot({super.key, this.color = AppColors.success});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
