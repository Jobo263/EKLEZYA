import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class LiturgicalColorBadge extends StatelessWidget {
  final String colorName;
  final String seasonName;
  final String? celebrationName;
  final String seasonKey;
  final bool compact;

  const LiturgicalColorBadge({
    super.key,
    required this.colorName,
    required this.seasonName,
    this.celebrationName,
    required this.seasonKey,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.liturgicalColorFromSeason(seasonKey);
    final bgColor = AppColors.liturgicalColorBgFromSeason(seasonKey);

    if (compact) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            celebrationName != null && celebrationName!.isNotEmpty
                ? celebrationName!
                : '$seasonName — $colorName',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color == AppColors.liturgicalWhite
                  ? AppColors.accentDark
                  : color,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
