import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../domain/entities/bible_verse.dart';

class VerseCard extends StatelessWidget {
  final BibleVerse verse;
  final bool showActions;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final VoidCallback? onHighlight;

  const VerseCard({
    super.key,
    required this.verse,
    this.showActions = true,
    this.onFavorite,
    this.onShare,
    this.onHighlight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gold top bar
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: AppColors.accentGradient,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Verse text
                  Text(
                    '"${verse.text}"',
                    style: AppTextStyles.verseText.copyWith(fontSize: 20),
                  ),

                  const SizedBox(height: 16),

                  // Reference row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          verse.reference,
                          style: AppTextStyles.verseReference,
                        ),
                      ),
                      if (verse.translation.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            verse.translation,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),

                  if (showActions) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    Row(
                      children: [
                        _ActionButton(
                          icon: verse.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: verse.isFavorite
                              ? AppColors.error
                              : AppColors.mediumGray,
                          onTap: onFavorite ?? () {},
                        ),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          color: AppColors.mediumGray,
                          onTap: onShare ?? () {},
                        ),
                        _ActionButton(
                          icon: Icons.highlight,
                          color: AppColors.mediumGray,
                          onTap: onHighlight ?? () {},
                        ),
                        _ActionButton(
                          icon: Icons.copy_outlined,
                          color: AppColors.mediumGray,
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(
                                text:
                                    '"${verse.text}" — ${verse.reference}',
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Verset copié !'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 20),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      padding: const EdgeInsets.all(8),
    );
  }
}
