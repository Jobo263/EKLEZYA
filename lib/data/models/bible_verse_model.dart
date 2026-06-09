import '../../domain/entities/bible_verse.dart';

class BibleVerseModel extends BibleVerse {
  const BibleVerseModel({
    required super.id,
    required super.book,
    required super.bookAbbreviation,
    required super.bookNumber,
    required super.chapter,
    required super.verse,
    required super.text,
    required super.translation,
    required super.language,
    super.isHighlighted,
    super.highlightColor,
    super.isFavorite,
    super.note,
  });

  factory BibleVerseModel.fromJson(Map<String, dynamic> json) {
    return BibleVerseModel(
      id: json['id'] as String? ??
          '${json['bookId']}_${json['chapter']}_${json['verse']}_${json['translation']}',
      book: json['book'] as String? ?? '',
      bookAbbreviation: json['bookAbbreviation'] as String? ??
          json['book_abbrev'] as String? ?? '',
      bookNumber: (json['bookNumber'] as num?)?.toInt() ??
          (json['book_number'] as num?)?.toInt() ?? 0,
      chapter: (json['chapter'] as num?)?.toInt() ?? 0,
      verse: (json['verse'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      translation: json['translation'] as String? ?? 'LSG',
      language: json['language'] as String? ?? 'fr',
      isHighlighted: json['isHighlighted'] as bool? ?? false,
      highlightColor: json['highlightColor'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'book': book,
      'bookAbbreviation': bookAbbreviation,
      'bookNumber': bookNumber,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'translation': translation,
      'language': language,
      'isHighlighted': isHighlighted,
      'highlightColor': highlightColor,
      'isFavorite': isFavorite,
      'note': note,
    };
  }

  factory BibleVerseModel.fromEntity(BibleVerse entity) {
    return BibleVerseModel(
      id: entity.id,
      book: entity.book,
      bookAbbreviation: entity.bookAbbreviation,
      bookNumber: entity.bookNumber,
      chapter: entity.chapter,
      verse: entity.verse,
      text: entity.text,
      translation: entity.translation,
      language: entity.language,
      isHighlighted: entity.isHighlighted,
      highlightColor: entity.highlightColor,
      isFavorite: entity.isFavorite,
      note: entity.note,
    );
  }

  /// Construct a Hive-compatible map for local caching.
  Map<String, dynamic> toHiveMap() => toJson();

  factory BibleVerseModel.fromHiveMap(Map<dynamic, dynamic> map) {
    return BibleVerseModel.fromJson(
      Map<String, dynamic>.from(map),
    );
  }
}

class BibleChapterModel extends BibleChapter {
  const BibleChapterModel({
    required super.book,
    required super.chapter,
    required super.verses,
    required super.translation,
  });

  factory BibleChapterModel.fromJson(Map<String, dynamic> json) {
    final versesJson = json['verses'] as List<dynamic>? ?? [];
    return BibleChapterModel(
      book: json['book'] as String? ?? '',
      chapter: (json['chapter'] as num?)?.toInt() ?? 0,
      verses: versesJson
          .map((v) => BibleVerseModel.fromJson(v as Map<String, dynamic>))
          .toList(),
      translation: json['translation'] as String? ?? 'LSG',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book': book,
      'chapter': chapter,
      'verses': verses
          .map((v) => BibleVerseModel.fromEntity(v).toJson())
          .toList(),
      'translation': translation,
    };
  }
}
