import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/saints_provider.dart';
import '../../widgets/saint_card.dart';

class SaintsScreen extends ConsumerStatefulWidget {
  const SaintsScreen({super.key});

  @override
  ConsumerState<SaintsScreen> createState() => _SaintsScreenState();
}

class _SaintsScreenState extends ConsumerState<SaintsScreen> {
  final _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final saintOfDay = ref.watch(saintOfDayProvider);
    final allSaints = ref.watch(allSaintsProvider);
    final searchResults = ref.watch(saintsSearchProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.white, fontFamily: 'Lato'),
                decoration: const InputDecoration(
                  hintText: 'Chercher un saint...',
                  hintStyle: TextStyle(color: AppColors.lightGray),
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(saintsSearchProvider.notifier).search(q),
              )
            : const Text('Saints'),
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _isSearchMode = !_isSearchMode);
              if (!_isSearchMode) {
                _searchController.clear();
                ref.read(saintsSearchProvider.notifier).clear();
              }
            },
          ),
        ],
      ),
      body: _isSearchMode
          ? _buildSearch(searchResults)
          : _buildMain(saintOfDay, allSaints),
    );
  }

  Widget _buildMain(
    AsyncValue saintOfDay,
    AsyncValue allSaints,
  ) {
    return CustomScrollView(
      slivers: [
        // Saint of day banner
        SliverToBoxAdapter(
          child: saintOfDay.when(
            data: (saints) => saints.isEmpty
                ? const SizedBox.shrink()
                : _SaintOfDayBanner(saint: saints.first),
            loading: () => const SizedBox(
              height: 180,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // All saints header
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 18, color: AppColors.accent),
                SizedBox(width: 8),
                Text(
                  'TOUS LES SAINTS',
                  style: AppTextStyles.liturgicalLabel,
                ),
              ],
            ),
          ),
        ),

        // All saints list
        allSaints.when(
          data: (saints) => SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => SaintCard(
                saint: saints[i],
                onTap: () =>
                    context.push('/home/saints/detail/${saints[i].id}'),
              ),
              childCount: saints.length,
            ),
          ),
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Erreur: $e')),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }

  Widget _buildSearch(AsyncValue searchResults) {
    return searchResults.when(
      data: (saints) {
        if (saints.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search, size: 60, color: AppColors.mediumGray),
                SizedBox(height: 16),
                Text('Cherchez un saint par nom', style: AppTextStyles.bodyMedium),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: saints.length,
          itemBuilder: (context, i) => SaintCard(
            saint: saints[i],
            onTap: () => context.push('/home/saints/detail/${saints[i].id}'),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class _SaintOfDayBanner extends StatelessWidget {
  final dynamic saint;

  const _SaintOfDayBanner({required this.saint});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/home/saints/detail/${saint.id}'),
      child: Container(
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryDark, AppColors.primary],
          ),
        ),
        child: Row(
          children: [
            // Saint avatar
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.2),
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: const Icon(Icons.star, color: AppColors.accent, size: 36),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SAINT DU JOUR',
                    style: AppTextStyles.liturgicalLabel,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    saint.nameFr ?? saint.name,
                    style: const TextStyle(
                      fontFamily: 'CrimsonText',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.offWhite,
                    ),
                  ),
                  if (saint.shortBioFr != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      saint.shortBioFr!,
                      style: const TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        color: AppColors.lightGray,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const Icon(Icons.chevron_right, color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
