import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/saints_provider.dart';

class SaintDetailScreen extends ConsumerWidget {
  final String saintId;

  const SaintDetailScreen({super.key, required this.saintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saintAsync = ref.watch(saintDetailProvider(saintId));

    return saintAsync.when(
      data: (saint) {
        if (saint == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Saint')),
            body: const Center(child: Text('Saint introuvable')),
          );
        }
        return _SaintDetailBody(saint: saint);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Saint')),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Saint')),
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _SaintDetailBody extends StatelessWidget {
  final dynamic saint;

  const _SaintDetailBody({required this.saint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                saint.nameFr ?? saint.name,
                style: const TextStyle(
                  fontFamily: 'CrimsonText',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.offWhite,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Saint icon/image
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.15),
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                      child: saint.imageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                saint.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.star,
                                  color: AppColors.accent,
                                  size: 44,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.star,
                              color: AppColors.accent,
                              size: 44,
                            ),
                    ),

                    const SizedBox(height: 8),

                    // Categories
                    if (saint.categories != null &&
                        (saint.categories as List).isNotEmpty)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        children: [
                          for (final cat in (saint.categories as List<String>))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cat,
                                style: const TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 10,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta
                  _buildMetaRow(),

                  const SizedBox(height: 24),

                  // Quote
                  if (saint.quoteFr != null) ...[
                    _buildQuote(saint.quoteFr!),
                    const SizedBox(height: 24),
                  ],

                  // Biography
                  Text(
                    'BIOGRAPHIE',
                    style: AppTextStyles.liturgicalLabel,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    saint.biographyFr ?? saint.biography,
                    style: AppTextStyles.prayerText.copyWith(fontSize: 17),
                  ),

                  const SizedBox(height: 32),

                  // Prayer
                  if (saint.prayerFr != null) ...[
                    Text('PRIÈRE', style: AppTextStyles.liturgicalLabel),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.liturgicalGoldLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: Text(
                        saint.prayerFr!,
                        style: AppTextStyles.prayerText.copyWith(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Patronages
                  if (saint.patronages != null &&
                      (saint.patronages as List).isNotEmpty) ...[
                    Text('PATRONAGES', style: AppTextStyles.liturgicalLabel),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final p in (saint.patronages as List<String>))
                          Chip(
                            label: Text(p),
                            backgroundColor:
                                AppColors.primary.withOpacity(0.08),
                            labelStyle: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow() {
    final items = <(IconData, String)>[];

    if (saint.feastMonth != null && saint.feastDayOfMonth != null) {
      final months = [
        '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
        'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
      ];
      items.add((Icons.calendar_today, '${saint.feastDayOfMonth} ${months[saint.feastMonth]}'));
    }
    if (saint.birthYear != null) {
      items.add((Icons.cake_outlined, 'Né(e) en ${saint.birthYear}'));
    }
    if (saint.deathYear != null) {
      items.add((Icons.church_outlined, 'Décédé(e) en ${saint.deathYear}'));
    }
    if (saint.canonizedBy != null) {
      items.add((Icons.verified, 'Canonisé par ${saint.canonizedBy}'));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(item.$2, style: AppTextStyles.bodySmall),
                ],
              ))
          .toList(),
    );
  }

  Widget _buildQuote(String quote) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: AppColors.accent, width: 3),
        ),
      ),
      child: Text(
        '"$quote"',
        style: AppTextStyles.verseText.copyWith(fontSize: 20),
      ),
    );
  }
}
