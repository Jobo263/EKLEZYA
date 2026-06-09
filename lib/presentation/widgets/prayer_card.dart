import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/prayer.dart';

class PrayerCard extends StatelessWidget {
  final Prayer prayer;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const PrayerCard({
    super.key,
    required this.prayer,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(prayer.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.lightDivider),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 4,
                height: 80,
                color: color,
              ),

              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayer.getTitle('fr'),
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        prayer.getBody('fr'),
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _categoryLabel(prayer.category),
                              style: TextStyle(
                                fontFamily: 'Lato',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          if (prayer.estimatedDurationSeconds != null) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: AppColors.mediumGray,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '~${(prayer.estimatedDurationSeconds! / 60).ceil()} min',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onFavorite != null)
                    IconButton(
                      icon: Icon(
                        prayer.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                        color: prayer.isFavorite
                            ? AppColors.error
                            : AppColors.mediumGray,
                      ),
                      onPressed: onFavorite,
                    ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.mediumGray,
                    size: 20,
                  ),
                ],
              ),

              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(PrayerCategory cat) {
    switch (cat) {
      case PrayerCategory.morning:
        return const Color(0xFFF57C00);
      case PrayerCategory.evening:
        return AppColors.primary;
      case PrayerCategory.rosary:
      case PrayerCategory.marian:
        return AppColors.liturgicalPurple;
      case PrayerCategory.litany:
        return const Color(0xFF1565C0);
      case PrayerCategory.chaplet:
        return const Color(0xFF00695C);
      case PrayerCategory.traditional:
        return AppColors.accentDark;
      case PrayerCategory.liturgical:
        return AppColors.liturgicalGreen;
      default:
        return AppColors.mediumGray;
    }
  }

  String _categoryLabel(PrayerCategory cat) {
    switch (cat) {
      case PrayerCategory.morning:
        return 'Matin';
      case PrayerCategory.evening:
        return 'Soir';
      case PrayerCategory.rosary:
        return 'Chapelet';
      case PrayerCategory.litany:
        return 'Litanie';
      case PrayerCategory.novena:
        return 'Neuvaine';
      case PrayerCategory.chaplet:
        return 'Chapelet';
      case PrayerCategory.traditional:
        return 'Tradition';
      case PrayerCategory.marian:
        return 'Mariale';
      case PrayerCategory.liturgical:
        return 'Liturgique';
      case PrayerCategory.reconciliation:
        return 'Réconciliation';
      case PrayerCategory.thanksgiving:
        return 'Actions de grâce';
      case PrayerCategory.intercession:
        return 'Intercession';
      case PrayerCategory.other:
        return 'Prière';
    }
  }
}
