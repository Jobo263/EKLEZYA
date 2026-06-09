import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bible_provider.dart';
import '../../providers/liturgy_provider.dart';
import '../../providers/saints_provider.dart';
import '../../widgets/liturgical_color_badge.dart';
import '../../widgets/saint_card.dart';
import '../../widgets/streak_display.dart';
import '../../widgets/verse_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _greeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour, $name !';
    if (hour < 18) return 'Bon après-midi, $name !';
    return 'Bonsoir, $name !';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final verseOfDay = ref.watch(verseOfDayProvider);
    final saintOfDay = ref.watch(saintOfDayProvider);
    final todayLiturgy = ref.watch(todayLiturgicalDayProvider);

    final firstName = profile?.firstName ?? 'Ami';
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(firstName),
                                    style: const TextStyle(
                                      fontFamily: 'CrimsonText',
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.offWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 12,
                                      color: AppColors.lightGray,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Profile avatar
                            GestureDetector(
                              onTap: () => context.push(AppRoutes.profile),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.accent,
                                backgroundImage: profile?.photoUrl != null
                                    ? NetworkImage(profile!.photoUrl!)
                                    : null,
                                child: profile?.photoUrl == null
                                    ? Text(
                                        firstName.isNotEmpty
                                            ? firstName[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          fontFamily: 'Lato',
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryDark,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Liturgical badge
                        todayLiturgy.when(
                          data: (day) => LiturgicalColorBadge(
                            colorName: day.colorName,
                            seasonName: day.seasonName,
                            celebrationName: day.celebrationName,
                            seasonKey: day.seasonKey,
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Streak ──────────────────────────────────────────
                  if (profile != null)
                    StreakDisplay(streak: profile.stats.currentStreak),

                  const SizedBox(height: 20),

                  // ── Verse of Day ─────────────────────────────────────
                  _sectionHeader('Verset du Jour', Icons.format_quote),
                  const SizedBox(height: 10),
                  verseOfDay.when(
                    data: (verse) => VerseCard(verse: verse),
                    loading: () => const _LoadingCard(height: 140),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),

                  const SizedBox(height: 24),

                  // ── Saint of Day ─────────────────────────────────────
                  _sectionHeader('Saint du Jour', Icons.star_outline),
                  const SizedBox(height: 10),
                  saintOfDay.when(
                    data: (saints) => saints.isEmpty
                        ? const _EmptyCard(message: 'Aucun saint assigné à ce jour')
                        : SaintCard(
                            saint: saints.first,
                            onTap: () => context.push(
                              '${AppRoutes.saints}/detail/${saints.first.id}',
                            ),
                          ),
                    loading: () => const _LoadingCard(height: 110),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),

                  const SizedBox(height: 24),

                  // ── Quick Actions ────────────────────────────────────
                  _sectionHeader('Actions rapides', Icons.bolt),
                  const SizedBox(height: 12),
                  _QuickActions(),

                  const SizedBox(height: 24),

                  // ── Liturgical Day Detail ────────────────────────────
                  _sectionHeader('Jour liturgique', Icons.calendar_today_outlined),
                  const SizedBox(height: 10),
                  todayLiturgy.when(
                    data: (day) => _LiturgicalDayCard(day: day),
                    loading: () => const _LoadingCard(height: 80),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 100), // FAB clearance
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.menu_book_outlined, 'Bible', AppColors.primary, AppRoutes.bible),
      (Icons.self_improvement, 'Prières', AppColors.liturgicalPurple, AppRoutes.prayers),
      (Icons.calendar_month, 'Liturgie', AppColors.liturgicalGold, AppRoutes.liturgy),
      (Icons.psychology, 'IA', AppColors.info, AppRoutes.aiChat),
    ];

    return Row(
      children: actions
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _QuickActionButton(
                    icon: a.$1,
                    label: a.$2,
                    color: a.$3,
                    onTap: () => context.push(a.$4),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiturgicalDayCard extends StatelessWidget {
  final dynamic day;

  const _LiturgicalDayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.left(
          color: AppColors.liturgicalColorFromSeason(day.seasonKey),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.seasonName,
            style: AppTextStyles.liturgicalLabel,
          ),
          if (day.weekOfSeason != null) ...[
            const SizedBox(height: 2),
            Text(
              'Semaine ${day.weekOfSeason} — ${day.weekdayName}',
              style: AppTextStyles.bodySmall,
            ),
          ],
          if (day.celebrationName != null) ...[
            const SizedBox(height: 6),
            Text(
              day.celebrationName!,
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Erreur: $message',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.mediumGray),
        textAlign: TextAlign.center,
      ),
    );
  }
}
