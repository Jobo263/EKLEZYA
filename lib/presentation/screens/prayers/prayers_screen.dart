import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/prayer.dart';
import '../../providers/prayer_provider.dart';
import '../../widgets/prayer_card.dart';

class PrayersScreen extends ConsumerWidget {
  const PrayersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Prières'),
          bottom: const TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.lightGray,
            indicatorColor: AppColors.accent,
            isScrollable: true,
            tabs: [
              Tab(text: 'Quotidiennes'),
              Tab(text: 'Chapelet'),
              Tab(text: 'Litanies'),
              Tab(text: 'Favorites'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DailyPrayersTab(),
            _RosaryTab(),
            _CategoryTab(category: PrayerCategory.litany),
            _FavoritesTab(),
          ],
        ),
      ),
    );
  }
}

class _DailyPrayersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final isMorning = hour < 12;
    final prayers = ref.watch(prayersByCategoryProvider(
      isMorning ? PrayerCategory.morning : PrayerCategory.evening,
    ));
    final traditional = ref.watch(prayersByCategoryProvider(PrayerCategory.traditional));

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isMorning ? Icons.wb_sunny : Icons.nights_stay,
                        color: AppColors.accent,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMorning
                                ? 'Prières du matin'
                                : 'Prières du soir',
                            style: const TextStyle(
                              fontFamily: 'CrimsonText',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.offWhite,
                            ),
                          ),
                          Text(
                            isMorning
                                ? 'Commencez votre journée avec Dieu'
                                : 'Terminez votre journée en prière',
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 12,
                              color: AppColors.lightGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                prayers.when(
                  data: (list) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: list
                        .map((p) => PrayerCard(
                              prayer: p,
                              onTap: () => context
                                  .push('/home/prayers/detail/${p.id}'),
                            ))
                        .toList(),
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                  error: (e, _) => Text('Erreur: $e'),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    const Icon(Icons.church, size: 16, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      'PRIÈRES TRADITIONNELLES',
                      style: AppTextStyles.liturgicalLabel,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                traditional.when(
                  data: (list) => Column(
                    children: list
                        .map((p) => PrayerCard(
                              prayer: p,
                              onTap: () => context
                                  .push('/home/prayers/detail/${p.id}'),
                            ))
                        .toList(),
                  ),
                  loading: () => const CircularProgressIndicator(
                    color: AppColors.accent,
                  ),
                  error: (e, _) => Text('Erreur: $e'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RosaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Rosary banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A0080), Color(0xFF6A1B9A)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.circle, color: AppColors.accent, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Le Chapelet',
                  style: TextStyle(
                    fontFamily: 'CrimsonText',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.offWhite,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Méditez les mystères du Rosaire\navec Marie',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    color: AppColors.lightGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push('/home/prayers/rosary'),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  label: const Text('Commencer le Chapelet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mystery types
          ...['Joyeux', 'Douloureux', 'Glorieux', 'Lumineux'].map(
            (mystery) => ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.liturgicalPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle,
                    color: AppColors.liturgicalPurple, size: 16),
              ),
              title: Text(
                'Mystères $mystery',
                style: AppTextStyles.titleSmall,
              ),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.mediumGray),
              onTap: () => context.push('/home/prayers/rosary'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends ConsumerWidget {
  final PrayerCategory category;

  const _CategoryTab({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayersByCategoryProvider(category));
    return prayers.when(
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, i) => PrayerCard(
          prayer: list[i],
          onTap: () => context.push('/home/prayers/detail/${list[i].id}'),
        ),
      ),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePrayersProvider);
    return favorites.when(
      data: (list) => list.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border,
                      size: 60, color: AppColors.mediumGray),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune prière favorite\npour le moment',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) => PrayerCard(
                prayer: list[i],
                onTap: () =>
                    context.push('/home/prayers/detail/${list[i].id}'),
              ),
            ),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}
