import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/streak_display.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const Scaffold(
            body: Center(child: Text('Non connecté')),
          );
        }
        return _ProfileBody(profile: profile);
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserProfile profile;

  const _ProfileBody({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _showEditProfile(context, ref),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Avatar
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.accent,
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                profile.displayName.isNotEmpty
                                    ? profile.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontFamily: 'CrimsonText',
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontFamily: 'CrimsonText',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.offWhite,
                        ),
                      ),
                      Text(
                        profile.email,
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          color: AppColors.lightGray,
                        ),
                      ),
                      if (profile.isPremium) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✦ PREMIUM',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak
                  StreakDisplay(streak: profile.stats.currentStreak),

                  const SizedBox(height: 24),

                  // Stats grid
                  _StatsGrid(stats: profile.stats),

                  const SizedBox(height: 24),

                  // Badges
                  if (profile.badges.isNotEmpty) ...[
                    const Text('MES MÉDAILLES',
                        style: AppTextStyles.liturgicalLabel),
                    const SizedBox(height: 12),
                    _BadgesRow(badges: profile.badges),
                    const SizedBox(height: 24),
                  ],

                  // Parish info
                  if (profile.parishName != null) ...[
                    const Text('MA PAROISSE',
                        style: AppTextStyles.liturgicalLabel),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.church,
                          color: AppColors.accent),
                      title: Text(profile.parishName!,
                          style: AppTextStyles.titleSmall),
                      subtitle: profile.dioceseName != null
                          ? Text(profile.dioceseName!,
                              style: AppTextStyles.bodySmall)
                          : null,
                      tileColor: AppColors.lightCard,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Settings
                  const Text('PARAMÈTRES', style: AppTextStyles.liturgicalLabel),
                  const SizedBox(height: 8),
                  _SettingsSection(profile: profile),

                  const SizedBox(height: 24),

                  // Premium
                  if (!profile.isPremium) _PremiumBanner(),

                  const SizedBox(height: 24),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(userProfileProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Se déconnecter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'EKLEZYA v1.0.0',
                      style: AppTextStyles.caption,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _EditProfileSheet(),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('🙏', '${stats.totalPrayersCompleted}', 'Prières'),
      ('📖', '${stats.totalBibleChaptersRead}', 'Chapitres'),
      ('🤖', '${stats.totalAiConversations}', 'Conv. IA'),
      ('🔥', '${stats.longestStreak}j', 'Meilleure série'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: items
          .map((item) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightDivider),
                ),
                child: Row(
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.$2,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.primary),
                        ),
                        Text(item.$3, style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

class _BadgesRow extends StatelessWidget {
  final List<dynamic> badges;

  const _BadgesRow({required this.badges});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final badge = badges[i];
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.accent, width: 1.5),
                ),
                child: const Icon(Icons.star, color: AppColors.accent, size: 24),
              ),
              const SizedBox(height: 4),
              Text(
                badge.nameFr ?? badge.name,
                style: AppTextStyles.caption,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  final UserProfile profile;

  const _SettingsSection({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            trailing: Switch(
              value: profile.notificationsEnabled,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.brightness_2_outlined,
            label: 'Mode sombre',
            trailing: Switch(
              value: profile.darkModeEnabled,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.language,
            label: 'Langue',
            trailing: Text(
              profile.preferredLanguage == 'fr' ? 'Français' : 'English',
              style: AppTextStyles.bodySmall,
            ),
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.menu_book_outlined,
            label: 'Traduction Bible',
            trailing: Text(
              profile.preferredBibleTranslation,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 20),
      title: Text(label, style: AppTextStyles.bodyMedium),
      trailing: trailing,
    );
  }
}

class _PremiumBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '✦ EKLEZYA PREMIUM',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accédez à toutes les fonctionnalités\net approfondir votre foi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'CrimsonText',
              fontSize: 18,
              color: AppColors.offWhite,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '• Bible complète avec audio  • IA illimitée\n• Chapelet interactif  • Contenu offline',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 12,
              color: AppColors.lightGray,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.primaryDark,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Passer à Premium',
              style: TextStyle(
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileSheet extends StatelessWidget {
  const _EditProfileSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Modifier le profil', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Nom complet'),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(labelText: 'Ma paroisse'),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(labelText: 'Mon diocèse'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
