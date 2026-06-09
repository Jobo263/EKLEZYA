import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/bible_verse.dart';
import '../../providers/bible_provider.dart';

class BibleScreen extends ConsumerStatefulWidget {
  const BibleScreen({super.key});

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearchMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.white, fontFamily: 'Lato'),
                decoration: const InputDecoration(
                  hintText: 'Rechercher dans la Bible...',
                  hintStyle: TextStyle(color: AppColors.lightGray),
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(bibleSearchProvider.notifier).search(q),
              )
            : const Text('Bible'),
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _isSearchMode = !_isSearchMode);
              if (!_isSearchMode) {
                _searchController.clear();
                ref.read(bibleSearchProvider.notifier).clear();
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (t) =>
                ref.read(bibleTranslationProvider.notifier).state = t,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'LSG', child: Text('Louis Segond (LSG)')),
              PopupMenuItem(value: 'TOB', child: Text('TOB')),
              PopupMenuItem(value: 'JER', child: Text('Bible de Jérusalem')),
            ],
          ),
        ],
        bottom: _isSearchMode
            ? null
            : TabBar(
                controller: _tabController,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.lightGray,
                indicatorColor: AppColors.accent,
                tabs: const [
                  Tab(text: 'Ancien Testament'),
                  Tab(text: 'Nouveau Testament'),
                ],
              ),
      ),
      body: _isSearchMode ? _buildSearchResults() : _buildBooksView(),
    );
  }

  Widget _buildBooksView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _BooksList(isOldTestament: true),
        _BooksList(isOldTestament: false),
      ],
    );
  }

  Widget _buildSearchResults() {
    final searchState = ref.watch(bibleSearchProvider);
    return searchState.when(
      data: (verses) {
        if (verses.isEmpty && _searchController.text.isNotEmpty) {
          return const Center(
            child: Text(
              'Aucun résultat trouvé',
              style: AppTextStyles.bodyMedium,
            ),
          );
        }
        if (verses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.search, size: 60, color: AppColors.mediumGray),
                SizedBox(height: 16),
                Text(
                  'Cherchez dans la Parole de Dieu',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: verses.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) => _VerseSearchResult(verse: verses[i]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }
}

class _BooksList extends ConsumerWidget {
  final bool isOldTestament;

  const _BooksList({required this.isOldTestament});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = isOldTestament
        ? ref.watch(oldTestamentBooksProvider)
        : ref.watch(newTestamentBooksProvider);

    return booksAsync.when(
      data: (books) {
        // Group by category
        final categories = <String, List<BibleBook>>{};
        for (final book in books) {
          categories.putIfAbsent(book.category, () => []).add(book);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final cat = categories.keys.toList()[i];
            final catBooks = categories[cat]!;
            return _BookCategory(
              category: _categoryName(cat),
              books: catBooks,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  String _categoryName(String key) {
    const names = {
      'pentateuch': 'Pentateuque',
      'historical': 'Livres historiques',
      'wisdom': 'Livres sapientiaux',
      'prophets': 'Livres prophétiques',
      'gospels': 'Évangiles',
      'acts': 'Actes des Apôtres',
      'letters': 'Épîtres',
      'apocalypse': 'Apocalypse',
    };
    return names[key] ?? key;
  }
}

class _BookCategory extends StatelessWidget {
  final String category;
  final List<BibleBook> books;

  const _BookCategory({required this.category, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            category.toUpperCase(),
            style: AppTextStyles.liturgicalLabel,
          ),
        ),
        ...books.map((book) => _BookTile(book: book)),
      ],
    );
  }
}

class _BookTile extends ConsumerWidget {
  final BibleBook book;

  const _BookTile({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            book.abbreviation,
            style: const TextStyle(
              fontFamily: 'CrimsonText',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: Text(book.nameFr, style: AppTextStyles.titleSmall),
      subtitle: Text(
        '${book.totalChapters} chapitres',
        style: AppTextStyles.bodySmall,
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.mediumGray,
        size: 20,
      ),
      onTap: () => context.push(
        '/home/bible/reader',
        extra: {'bookId': book.id, 'chapter': 1},
      ),
    );
  }
}

class _VerseSearchResult extends StatelessWidget {
  final BibleVerse verse;

  const _VerseSearchResult({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            verse.shortReference,
            style: AppTextStyles.verseReference,
          ),
          const SizedBox(height: 4),
          Text(
            verse.text,
            style: AppTextStyles.verseText.copyWith(fontSize: 16),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
