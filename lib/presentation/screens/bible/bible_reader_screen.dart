import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/bible_verse.dart';
import '../../../domain/usecases/bible/highlight_verse.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bible_provider.dart';

class BibleReaderScreen extends ConsumerStatefulWidget {
  final String bookId;
  final int chapter;

  const BibleReaderScreen({
    super.key,
    required this.bookId,
    required this.chapter,
  });

  @override
  ConsumerState<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends ConsumerState<BibleReaderScreen> {
  late String _bookId;
  late int _chapter;
  final Set<String> _selectedVerses = {};
  bool _showControls = true;

  static const _highlightColors = [
    '#FFFF8D', // yellow
    '#A5D6A7', // green
    '#90CAF9', // blue
    '#FFAB91', // orange
    '#CE93D8', // purple
  ];

  @override
  void initState() {
    super.initState();
    _bookId = widget.bookId;
    _chapter = widget.chapter;
  }

  @override
  Widget build(BuildContext context) {
    final translation = ref.watch(bibleTranslationProvider);
    final language = ref.watch(bibleLanguageProvider);
    final fontSize = ref.watch(bibleFontSizeProvider);
    final nightMode = ref.watch(bibleNightModeProvider);

    final chapterAsync =
        ref.watch(chapterProvider((_bookId, _chapter)));

    final bgColor = nightMode ? const Color(0xFF1A1510) : AppColors.lightBackground;
    final textColor = nightMode ? AppColors.offWhite : AppColors.primary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _showControls
          ? AppBar(
              title: chapterAsync.when(
                data: (ch) => Text('${ch.book} ${ch.chapter}'),
                loading: () => const Text('Chargement...'),
                error: (_, __) => const Text('Erreur'),
              ),
              actions: [
                // Font size
                PopupMenuButton<double>(
                  icon: const Icon(Icons.format_size),
                  onSelected: (size) =>
                      ref.read(bibleFontSizeProvider.notifier).state = size,
                  itemBuilder: (_) => [14.0, 16.0, 18.0, 20.0, 22.0, 24.0]
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text('${s.toInt()}pt'),
                          ))
                      .toList(),
                ),
                // Night mode
                IconButton(
                  icon: Icon(nightMode
                      ? Icons.brightness_7
                      : Icons.brightness_2),
                  onPressed: () => ref
                      .read(bibleNightModeProvider.notifier)
                      .state = !nightMode,
                ),
                // Chapter navigation
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: _showChapterPicker,
                ),
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: chapterAsync.when(
          data: (chapter) => _buildReader(chapter, fontSize, textColor, bgColor),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(child: Text('Erreur: $e')),
        ),
      ),
      bottomSheet: _selectedVerses.isNotEmpty
          ? _buildVerseActions()
          : null,
    );
  }

  Widget _buildReader(
    BibleChapter chapter,
    double fontSize,
    Color textColor,
    Color bgColor,
  ) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          itemCount: chapter.verses.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return _buildChapterNav(chapter);
            }
            final verse = chapter.verses[i - 1];
            return _VerseItem(
              verse: verse,
              fontSize: fontSize,
              textColor: textColor,
              isSelected: _selectedVerses.contains(verse.id),
              onTap: () => _toggleVerse(verse.id),
              onLongPress: () => _selectVerse(verse.id),
            );
          },
        ),

        // Chapter navigation arrows
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_chapter > 1)
                _NavArrow(
                  icon: Icons.chevron_left,
                  onTap: () => setState(() => _chapter--),
                ),
              const Spacer(),
              _NavArrow(
                icon: Icons.chevron_right,
                onTap: () => setState(() => _chapter++),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapterNav(BibleChapter chapter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Chapitre ${chapter.chapter}',
        style: AppTextStyles.displaySmall.copyWith(
          color: AppColors.accent,
          textBaseline: TextBaseline.alphabetic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVerseActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.lightSurface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedVerses.length} verset(s) sélectionné(s)',
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 12),
          // Highlight colors
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _highlightColors.map((colorHex) {
              final color = Color(
                int.parse('FF${colorHex.substring(1)}', radix: 16),
              );
              return GestureDetector(
                onTap: () => _highlightSelected(colorHex),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lightDivider),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Partager'),
                onPressed: _shareSelected,
              ),
              TextButton.icon(
                icon: const Icon(Icons.favorite_border, size: 18),
                label: const Text('Favori'),
                onPressed: _favoriteSelected,
              ),
              TextButton.icon(
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Annuler'),
                onPressed: () => setState(() => _selectedVerses.clear()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleVerse(String id) {
    if (_selectedVerses.isEmpty) return;
    setState(() {
      if (_selectedVerses.contains(id)) {
        _selectedVerses.remove(id);
      } else {
        _selectedVerses.add(id);
      }
    });
  }

  void _selectVerse(String id) {
    setState(() {
      if (_selectedVerses.contains(id)) {
        _selectedVerses.remove(id);
      } else {
        _selectedVerses.add(id);
      }
    });
  }

  Future<void> _highlightSelected(String colorHex) async {
    final uid = ref.read(currentUidProvider) ?? '';
    final highlightUseCase = HighlightVerseUseCase(
      ref.read(bibleRepositoryProvider),
    );
    for (final id in _selectedVerses) {
      await highlightUseCase(verseId: id, color: colorHex, userId: uid);
    }
    setState(() => _selectedVerses.clear());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verset(s) surlignés !')),
      );
    }
  }

  void _shareSelected() {
    // Would use share_plus
    setState(() => _selectedVerses.clear());
  }

  void _favoriteSelected() {
    setState(() => _selectedVerses.clear());
  }

  void _showChapterPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => _ChapterPicker(
        currentChapter: _chapter,
        onSelect: (ch) {
          setState(() => _chapter = ch);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class _VerseItem extends StatelessWidget {
  final BibleVerse verse;
  final double fontSize;
  final Color textColor;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _VerseItem({
    required this.verse,
    required this.fontSize,
    required this.textColor,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    if (isSelected) {
      bg = AppColors.accent.withOpacity(0.2);
    } else if (verse.isHighlighted && verse.highlightColor != null) {
      bg = Color(
        int.parse('CC${verse.highlightColor!.substring(1)}', radix: 16),
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${verse.verse} ',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: fontSize * 0.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                  height: fontSize / 12,
                ),
              ),
              TextSpan(
                text: verse.text,
                style: TextStyle(
                  fontFamily: 'CrimsonText',
                  fontSize: fontSize,
                  color: textColor,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.white),
      ),
    );
  }
}

class _ChapterPicker extends StatelessWidget {
  final int currentChapter;
  final ValueChanged<int> onSelect;

  const _ChapterPicker({
    required this.currentChapter,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Choisir un chapitre', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: 50, // will be dynamic in production
              itemBuilder: (context, i) {
                final ch = i + 1;
                final isSelected = ch == currentChapter;
                return GestureDetector(
                  onTap: () => onSelect(ch),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '$ch',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
