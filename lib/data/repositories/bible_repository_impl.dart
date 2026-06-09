import '../../domain/entities/bible_verse.dart';
import '../../domain/repositories/bible_repository.dart';
import '../datasources/firebase_bible_datasource.dart';
import '../datasources/local_bible_datasource.dart';
import '../models/bible_verse_model.dart';

class BibleRepositoryImpl implements BibleRepository {
  final FirebaseBibleDatasource _remote;
  final LocalBibleDatasource _local;

  // Fallback verse of the day (deterministic by day-of-year)
  static const _fallbackVerses = [
    ('Jn', 3, 16, 'Car Dieu a tant aimé le monde qu\'il a donné son Fils unique, afin que quiconque croit en lui ne se perde pas, mais ait la vie éternelle.'),
    ('Ps', 23, 1, 'Le Seigneur est mon berger, je ne manque de rien.'),
    ('Mt', 5, 9, 'Heureux les artisans de paix, car ils seront appelés fils de Dieu !'),
    ('Pr', 3, 5, 'Confie-toi en l\'Éternel de tout ton cœur, et ne t\'appuie pas sur ta propre intelligence.'),
    ('Ph', 4, 13, 'Je peux tout par celui qui me fortifie.'),
    ('Rm', 8, 28, 'Nous savons d\'ailleurs que toutes choses concourent au bien de ceux qui aiment Dieu.'),
    ('1Co', 13, 13, 'Maintenant donc ces trois choses demeurent : la foi, l\'espérance, la charité ; mais la plus grande, c\'est la charité.'),
  ];

  BibleRepositoryImpl({
    required FirebaseBibleDatasource remote,
    required LocalBibleDatasource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<BibleChapter> getChapter({
    required String bookId,
    required int chapter,
    required String translation,
    required String language,
  }) async {
    // Try local cache first
    final cached = await _local.getChapter(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
    );
    if (cached != null) return cached;

    // Fetch from remote
    final remote = await _remote.getChapter(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
      language: language,
    );

    // Cache locally
    await _local.saveChapter(remote, bookId);

    return remote;
  }

  @override
  Future<BibleVerse> getVerse({
    required String bookId,
    required int chapter,
    required int verse,
    required String translation,
    required String language,
  }) async {
    final chapterData = await getChapter(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
      language: language,
    );
    return chapterData.verses.firstWhere(
      (v) => v.verse == verse,
      orElse: () => chapterData.verses.first,
    );
  }

  @override
  Future<List<BibleVerse>> searchBible({
    required String query,
    required String translation,
    required String language,
    int limit = 20,
  }) async {
    return _remote.searchVerses(
      query: query,
      translation: translation,
      language: language,
      limit: limit,
    );
  }

  @override
  Future<List<BibleBook>> getAllBooks({required String language}) async {
    // In a real app, this would come from Firestore or a local JSON
    // For now, return a static list of the 73 Catholic canon books
    return _getCatholicBibleBooks(language);
  }

  @override
  Future<BibleVerse> getVerseOfDay({
    required DateTime date,
    required String translation,
    required String language,
  }) async {
    // Try remote first
    final remote = await _remote.getVerseOfDay(
      date: date,
      translation: translation,
      language: language,
    );
    if (remote != null) return remote;

    // Fallback: deterministic selection based on day of year
    final dayOfYear = int.parse(
      date.difference(DateTime(date.year, 1, 1)).inDays.toString(),
    );
    final idx = dayOfYear % _fallbackVerses.length;
    final (book, chap, ver, text) = _fallbackVerses[idx];

    return BibleVerseModel(
      id: 'votd_${date.year}_${date.month}_${date.day}',
      book: book,
      bookAbbreviation: book,
      bookNumber: 0,
      chapter: chap,
      verse: ver,
      text: text,
      translation: translation,
      language: language,
    );
  }

  @override
  Future<void> highlightVerse({
    required String verseId,
    required String color,
    required String userId,
  }) async {
    await Future.wait([
      _local.saveHighlight(verseId: verseId, color: color),
      _remote.saveHighlight(userId: userId, verseId: verseId, color: color),
    ]);
  }

  @override
  Future<void> removeHighlight({
    required String verseId,
    required String userId,
  }) async {
    await Future.wait([
      _local.removeHighlight(verseId),
      _remote.removeHighlight(userId: userId, verseId: verseId),
    ]);
  }

  @override
  Future<void> toggleFavorite({
    required String verseId,
    required String userId,
  }) async {
    final isFav = await _local.isFavorite(verseId);
    if (isFav) {
      await _local.removeFavorite(verseId);
    } else {
      await _local.saveFavorite(verseId);
    }
    await _remote.toggleFavorite(userId: userId, verseId: verseId);
  }

  @override
  Future<void> saveVerseNote({
    required String verseId,
    required String note,
    required String userId,
  }) async {
    await _local.saveNote(verseId: verseId, note: note);
    await _remote.saveNote(userId: userId, verseId: verseId, note: note);
  }

  @override
  Future<List<BibleVerse>> getUserHighlights({required String userId}) async {
    // Simplified: return empty for now, would normally fetch and join verses
    return [];
  }

  @override
  Future<List<BibleVerse>> getUserFavorites({required String userId}) async {
    return [];
  }

  @override
  Future<void> cacheChapter(BibleChapter chapter) async {
    if (chapter is BibleChapterModel) {
      await _local.saveChapter(chapter, chapter.book);
    }
  }

  @override
  Future<bool> isChapterCached({
    required String bookId,
    required int chapter,
    required String translation,
  }) async {
    return _local.isChapterCached(
      bookId: bookId,
      chapter: chapter,
      translation: translation,
    );
  }

  // ── Static Bible book metadata ────────────────────────────────────────────

  static List<BibleBook> _getCatholicBibleBooks(String language) {
    return [
      // Old Testament (46 books)
      BibleBook(id: 'gn', name: 'Genesis', nameFr: 'Genèse', abbreviation: 'Gn', bookNumber: 1, totalChapters: 50, isOldTestament: true, category: 'pentateuch'),
      BibleBook(id: 'ex', name: 'Exodus', nameFr: 'Exode', abbreviation: 'Ex', bookNumber: 2, totalChapters: 40, isOldTestament: true, category: 'pentateuch'),
      BibleBook(id: 'lv', name: 'Leviticus', nameFr: 'Lévitique', abbreviation: 'Lv', bookNumber: 3, totalChapters: 27, isOldTestament: true, category: 'pentateuch'),
      BibleBook(id: 'nb', name: 'Numbers', nameFr: 'Nombres', abbreviation: 'Nb', bookNumber: 4, totalChapters: 36, isOldTestament: true, category: 'pentateuch'),
      BibleBook(id: 'dt', name: 'Deuteronomy', nameFr: 'Deutéronome', abbreviation: 'Dt', bookNumber: 5, totalChapters: 34, isOldTestament: true, category: 'pentateuch'),
      BibleBook(id: 'jos', name: 'Joshua', nameFr: 'Josué', abbreviation: 'Jos', bookNumber: 6, totalChapters: 24, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'jg', name: 'Judges', nameFr: 'Juges', abbreviation: 'Jg', bookNumber: 7, totalChapters: 21, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'rt', name: 'Ruth', nameFr: 'Ruth', abbreviation: 'Rt', bookNumber: 8, totalChapters: 4, isOldTestament: true, category: 'historical'),
      BibleBook(id: '1s', name: '1 Samuel', nameFr: '1 Samuel', abbreviation: '1S', bookNumber: 9, totalChapters: 31, isOldTestament: true, category: 'historical'),
      BibleBook(id: '2s', name: '2 Samuel', nameFr: '2 Samuel', abbreviation: '2S', bookNumber: 10, totalChapters: 24, isOldTestament: true, category: 'historical'),
      BibleBook(id: '1r', name: '1 Kings', nameFr: '1 Rois', abbreviation: '1R', bookNumber: 11, totalChapters: 22, isOldTestament: true, category: 'historical'),
      BibleBook(id: '2r', name: '2 Kings', nameFr: '2 Rois', abbreviation: '2R', bookNumber: 12, totalChapters: 25, isOldTestament: true, category: 'historical'),
      BibleBook(id: '1ch', name: '1 Chronicles', nameFr: '1 Chroniques', abbreviation: '1Ch', bookNumber: 13, totalChapters: 29, isOldTestament: true, category: 'historical'),
      BibleBook(id: '2ch', name: '2 Chronicles', nameFr: '2 Chroniques', abbreviation: '2Ch', bookNumber: 14, totalChapters: 36, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'esd', name: 'Ezra', nameFr: 'Esdras', abbreviation: 'Esd', bookNumber: 15, totalChapters: 10, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'ne', name: 'Nehemiah', nameFr: 'Néhémie', abbreviation: 'Ne', bookNumber: 16, totalChapters: 13, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'tb', name: 'Tobit', nameFr: 'Tobie', abbreviation: 'Tb', bookNumber: 17, totalChapters: 14, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'jdt', name: 'Judith', nameFr: 'Judith', abbreviation: 'Jdt', bookNumber: 18, totalChapters: 16, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'est', name: 'Esther', nameFr: 'Esther', abbreviation: 'Est', bookNumber: 19, totalChapters: 10, isOldTestament: true, category: 'historical'),
      BibleBook(id: '1m', name: '1 Maccabees', nameFr: '1 Maccabées', abbreviation: '1M', bookNumber: 20, totalChapters: 16, isOldTestament: true, category: 'historical'),
      BibleBook(id: '2m', name: '2 Maccabees', nameFr: '2 Maccabées', abbreviation: '2M', bookNumber: 21, totalChapters: 15, isOldTestament: true, category: 'historical'),
      BibleBook(id: 'jb', name: 'Job', nameFr: 'Job', abbreviation: 'Jb', bookNumber: 22, totalChapters: 42, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'ps', name: 'Psalms', nameFr: 'Psaumes', abbreviation: 'Ps', bookNumber: 23, totalChapters: 150, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'pr', name: 'Proverbs', nameFr: 'Proverbes', abbreviation: 'Pr', bookNumber: 24, totalChapters: 31, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'qo', name: 'Ecclesiastes', nameFr: 'Qohéleth', abbreviation: 'Qo', bookNumber: 25, totalChapters: 12, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'ct', name: 'Song of Songs', nameFr: 'Cantique des Cantiques', abbreviation: 'Ct', bookNumber: 26, totalChapters: 8, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'sg', name: 'Wisdom', nameFr: 'Sagesse', abbreviation: 'Sg', bookNumber: 27, totalChapters: 19, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'si', name: 'Sirach', nameFr: 'Siracide', abbreviation: 'Si', bookNumber: 28, totalChapters: 51, isOldTestament: true, category: 'wisdom'),
      BibleBook(id: 'is', name: 'Isaiah', nameFr: 'Isaïe', abbreviation: 'Is', bookNumber: 29, totalChapters: 66, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'jr', name: 'Jeremiah', nameFr: 'Jérémie', abbreviation: 'Jr', bookNumber: 30, totalChapters: 52, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'lm', name: 'Lamentations', nameFr: 'Lamentations', abbreviation: 'Lm', bookNumber: 31, totalChapters: 5, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ba', name: 'Baruch', nameFr: 'Baruch', abbreviation: 'Ba', bookNumber: 32, totalChapters: 6, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ez', name: 'Ezekiel', nameFr: 'Ézéchiel', abbreviation: 'Ez', bookNumber: 33, totalChapters: 48, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'dn', name: 'Daniel', nameFr: 'Daniel', abbreviation: 'Dn', bookNumber: 34, totalChapters: 14, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'os', name: 'Hosea', nameFr: 'Osée', abbreviation: 'Os', bookNumber: 35, totalChapters: 14, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'jl', name: 'Joel', nameFr: 'Joël', abbreviation: 'Jl', bookNumber: 36, totalChapters: 4, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'am', name: 'Amos', nameFr: 'Amos', abbreviation: 'Am', bookNumber: 37, totalChapters: 9, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ab', name: 'Obadiah', nameFr: 'Abdias', abbreviation: 'Ab', bookNumber: 38, totalChapters: 1, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'jon', name: 'Jonah', nameFr: 'Jonas', abbreviation: 'Jon', bookNumber: 39, totalChapters: 4, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'mi', name: 'Micah', nameFr: 'Michée', abbreviation: 'Mi', bookNumber: 40, totalChapters: 7, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'na', name: 'Nahum', nameFr: 'Nahum', abbreviation: 'Na', bookNumber: 41, totalChapters: 3, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ha', name: 'Habakkuk', nameFr: 'Habacuc', abbreviation: 'Ha', bookNumber: 42, totalChapters: 3, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'so', name: 'Zephaniah', nameFr: 'Sophonie', abbreviation: 'So', bookNumber: 43, totalChapters: 3, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ag', name: 'Haggai', nameFr: 'Aggée', abbreviation: 'Ag', bookNumber: 44, totalChapters: 2, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'za', name: 'Zechariah', nameFr: 'Zacharie', abbreviation: 'Za', bookNumber: 45, totalChapters: 14, isOldTestament: true, category: 'prophets'),
      BibleBook(id: 'ml', name: 'Malachi', nameFr: 'Malachie', abbreviation: 'Ml', bookNumber: 46, totalChapters: 4, isOldTestament: true, category: 'prophets'),
      // New Testament (27 books)
      BibleBook(id: 'mt', name: 'Matthew', nameFr: 'Matthieu', abbreviation: 'Mt', bookNumber: 47, totalChapters: 28, isOldTestament: false, category: 'gospels'),
      BibleBook(id: 'mc', name: 'Mark', nameFr: 'Marc', abbreviation: 'Mc', bookNumber: 48, totalChapters: 16, isOldTestament: false, category: 'gospels'),
      BibleBook(id: 'lc', name: 'Luke', nameFr: 'Luc', abbreviation: 'Lc', bookNumber: 49, totalChapters: 24, isOldTestament: false, category: 'gospels'),
      BibleBook(id: 'jn', name: 'John', nameFr: 'Jean', abbreviation: 'Jn', bookNumber: 50, totalChapters: 21, isOldTestament: false, category: 'gospels'),
      BibleBook(id: 'ac', name: 'Acts', nameFr: 'Actes', abbreviation: 'Ac', bookNumber: 51, totalChapters: 28, isOldTestament: false, category: 'acts'),
      BibleBook(id: 'rm', name: 'Romans', nameFr: 'Romains', abbreviation: 'Rm', bookNumber: 52, totalChapters: 16, isOldTestament: false, category: 'letters'),
      BibleBook(id: '1co', name: '1 Corinthians', nameFr: '1 Corinthiens', abbreviation: '1Co', bookNumber: 53, totalChapters: 16, isOldTestament: false, category: 'letters'),
      BibleBook(id: '2co', name: '2 Corinthians', nameFr: '2 Corinthiens', abbreviation: '2Co', bookNumber: 54, totalChapters: 13, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'ga', name: 'Galatians', nameFr: 'Galates', abbreviation: 'Ga', bookNumber: 55, totalChapters: 6, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'ep', name: 'Ephesians', nameFr: 'Éphésiens', abbreviation: 'Ep', bookNumber: 56, totalChapters: 6, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'ph', name: 'Philippians', nameFr: 'Philippiens', abbreviation: 'Ph', bookNumber: 57, totalChapters: 4, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'col', name: 'Colossians', nameFr: 'Colossiens', abbreviation: 'Col', bookNumber: 58, totalChapters: 4, isOldTestament: false, category: 'letters'),
      BibleBook(id: '1th', name: '1 Thessalonians', nameFr: '1 Thessaloniciens', abbreviation: '1Th', bookNumber: 59, totalChapters: 5, isOldTestament: false, category: 'letters'),
      BibleBook(id: '2th', name: '2 Thessalonians', nameFr: '2 Thessaloniciens', abbreviation: '2Th', bookNumber: 60, totalChapters: 3, isOldTestament: false, category: 'letters'),
      BibleBook(id: '1tm', name: '1 Timothy', nameFr: '1 Timothée', abbreviation: '1Tm', bookNumber: 61, totalChapters: 6, isOldTestament: false, category: 'letters'),
      BibleBook(id: '2tm', name: '2 Timothy', nameFr: '2 Timothée', abbreviation: '2Tm', bookNumber: 62, totalChapters: 4, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'tt', name: 'Titus', nameFr: 'Tite', abbreviation: 'Tt', bookNumber: 63, totalChapters: 3, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'phm', name: 'Philemon', nameFr: 'Philémon', abbreviation: 'Phm', bookNumber: 64, totalChapters: 1, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'he', name: 'Hebrews', nameFr: 'Hébreux', abbreviation: 'He', bookNumber: 65, totalChapters: 13, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'jc', name: 'James', nameFr: 'Jacques', abbreviation: 'Jc', bookNumber: 66, totalChapters: 5, isOldTestament: false, category: 'letters'),
      BibleBook(id: '1p', name: '1 Peter', nameFr: '1 Pierre', abbreviation: '1P', bookNumber: 67, totalChapters: 5, isOldTestament: false, category: 'letters'),
      BibleBook(id: '2p', name: '2 Peter', nameFr: '2 Pierre', abbreviation: '2P', bookNumber: 68, totalChapters: 3, isOldTestament: false, category: 'letters'),
      BibleBook(id: '1jn', name: '1 John', nameFr: '1 Jean', abbreviation: '1Jn', bookNumber: 69, totalChapters: 5, isOldTestament: false, category: 'letters'),
      BibleBook(id: '2jn', name: '2 John', nameFr: '2 Jean', abbreviation: '2Jn', bookNumber: 70, totalChapters: 1, isOldTestament: false, category: 'letters'),
      BibleBook(id: '3jn', name: '3 John', nameFr: '3 Jean', abbreviation: '3Jn', bookNumber: 71, totalChapters: 1, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'jude', name: 'Jude', nameFr: 'Jude', abbreviation: 'Jude', bookNumber: 72, totalChapters: 1, isOldTestament: false, category: 'letters'),
      BibleBook(id: 'ap', name: 'Revelation', nameFr: 'Apocalypse', abbreviation: 'Ap', bookNumber: 73, totalChapters: 22, isOldTestament: false, category: 'apocalypse'),
    ];
  }
}
