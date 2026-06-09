import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/firebase_bible_datasource.dart';
import '../../data/datasources/local_bible_datasource.dart';
import '../../data/repositories/bible_repository_impl.dart';
import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../../domain/usecases/bible/get_chapter.dart';
import '../../domain/usecases/bible/search_bible.dart';
import 'auth_provider.dart';

// ── Repository ────────────────────────────────────────────────────────────

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl(
    remote: FirebaseBibleDatasource(ref.read(firestoreProvider)),
    local: LocalBibleDatasource(),
  );
});

// ── Use Cases ─────────────────────────────────────────────────────────────

final getChapterUseCaseProvider = Provider<GetChapterUseCase>((ref) {
  return GetChapterUseCase(ref.read(bibleRepositoryProvider));
});

final searchBibleUseCaseProvider = Provider<SearchBibleUseCase>((ref) {
  return SearchBibleUseCase(ref.read(bibleRepositoryProvider));
});

// ── Reading preferences ───────────────────────────────────────────────────

final bibleTranslationProvider = StateProvider<String>((ref) => 'LSG');
final bibleLanguageProvider = StateProvider<String>((ref) => 'fr');
final bibleFontSizeProvider = StateProvider<double>((ref) => 18.0);
final bibleNightModeProvider = StateProvider<bool>((ref) => false);

// Current reading position
final currentBookProvider = StateProvider<String>((ref) => 'jn');
final currentChapterProvider = StateProvider<int>((ref) => 1);

// ── Verse of day ──────────────────────────────────────────────────────────

final verseOfDayProvider = FutureProvider<BibleVerse>((ref) async {
  final repo = ref.read(bibleRepositoryProvider);
  final translation = ref.watch(bibleTranslationProvider);
  final language = ref.watch(bibleLanguageProvider);
  return repo.getVerseOfDay(
    date: DateTime.now(),
    translation: translation,
    language: language,
  );
});

// ── Chapter provider ──────────────────────────────────────────────────────

final chapterProvider = FutureProvider.family<BibleChapter, (String, int)>((
  ref,
  args,
) async {
  final (bookId, chapter) = args;
  final useCase = ref.read(getChapterUseCaseProvider);
  final translation = ref.watch(bibleTranslationProvider);
  final language = ref.watch(bibleLanguageProvider);
  return useCase(
    bookId: bookId,
    chapter: chapter,
    translation: translation,
    language: language,
  );
});

// ── All books ─────────────────────────────────────────────────────────────

final allBibleBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final repo = ref.read(bibleRepositoryProvider);
  final language = ref.watch(bibleLanguageProvider);
  return repo.getAllBooks(language: language);
});

final oldTestamentBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final books = await ref.watch(allBibleBooksProvider.future);
  return books.where((b) => b.isOldTestament).toList();
});

final newTestamentBooksProvider = FutureProvider<List<BibleBook>>((ref) async {
  final books = await ref.watch(allBibleBooksProvider.future);
  return books.where((b) => b.isNewTestament).toList();
});

// ── Search ────────────────────────────────────────────────────────────────

class BibleSearchNotifier extends StateNotifier<AsyncValue<List<BibleVerse>>> {
  final SearchBibleUseCase _useCase;
  final String _translation;
  final String _language;

  BibleSearchNotifier({
    required SearchBibleUseCase useCase,
    required String translation,
    required String language,
  })  : _useCase = useCase,
        _translation = translation,
        _language = language,
        super(const AsyncData([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _useCase(
        query: query,
        translation: _translation,
        language: _language,
      ),
    );
  }

  void clear() {
    state = const AsyncData([]);
  }
}

final bibleSearchProvider =
    StateNotifierProvider<BibleSearchNotifier, AsyncValue<List<BibleVerse>>>(
        (ref) {
  return BibleSearchNotifier(
    useCase: ref.read(searchBibleUseCaseProvider),
    translation: ref.read(bibleTranslationProvider),
    language: ref.read(bibleLanguageProvider),
  );
});

// ── Selected verses (for multi-select, share, etc.) ──────────────────────

final selectedVersesProvider = StateProvider<Set<String>>((ref) => {});
