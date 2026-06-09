import 'package:flutter/foundation.dart';

@immutable
class BibleVerse {
  final String id;
  final String book;
  final String bookAbbreviation;
  final int bookNumber;
  final int chapter;
  final int verse;
  final String text;
  final String translation;
  final String language;
  final bool isHighlighted;
  final String? highlightColor;
  final bool isFavorite;
  final String? note;

  const BibleVerse({
    required this.id,
    required this.book,
    required this.bookAbbreviation,
    required this.bookNumber,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.translation,
    required this.language,
    this.isHighlighted = false,
    this.highlightColor,
    this.isFavorite = false,
    this.note,
  });

  /// Human-readable reference, e.g. "Jean 3:16"
  String get reference => '$book $chapter:$verse';

  /// Short reference, e.g. "Jn 3:16"
  String get shortReference => '$bookAbbreviation $chapter:$verse';

  BibleVerse copyWith({
    String? id,
    String? book,
    String? bookAbbreviation,
    int? bookNumber,
    int? chapter,
    int? verse,
    String? text,
    String? translation,
    String? language,
    bool? isHighlighted,
    String? highlightColor,
    bool? isFavorite,
    String? note,
  }) {
    return BibleVerse(
      id: id ?? this.id,
      book: book ?? this.book,
      bookAbbreviation: bookAbbreviation ?? this.bookAbbreviation,
      bookNumber: bookNumber ?? this.bookNumber,
      chapter: chapter ?? this.chapter,
      verse: verse ?? this.verse,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      language: language ?? this.language,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      highlightColor: highlightColor ?? this.highlightColor,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleVerse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          translation == other.translation;

  @override
  int get hashCode => Object.hash(id, translation);
}

/// Represents a full chapter with its verses.
@immutable
class BibleChapter {
  final String book;
  final int chapter;
  final List<BibleVerse> verses;
  final String translation;

  const BibleChapter({
    required this.book,
    required this.chapter,
    required this.verses,
    required this.translation,
  });
}

/// Bible book metadata.
@immutable
class BibleBook {
  final String id;
  final String name;
  final String nameFr;
  final String abbreviation;
  final int bookNumber;
  final int totalChapters;
  final bool isOldTestament;
  final String category;

  const BibleBook({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.abbreviation,
    required this.bookNumber,
    required this.totalChapters,
    required this.isOldTestament,
    required this.category,
  });

  bool get isNewTestament => !isOldTestament;
}
