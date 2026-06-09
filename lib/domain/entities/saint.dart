import 'package:flutter/foundation.dart';

@immutable
class Saint {
  final String id;
  final String name;
  final String nameFr;
  final String nameEn;
  final String biography;
  final String biographyFr;
  final String biographyEn;
  final String? shortBio;
  final String? shortBioFr;
  final String? shortBioEn;
  final DateTime? feastDay;
  final int? feastMonth;
  final int? feastDayOfMonth;
  final String? birthYear;
  final String? deathYear;
  final String? birthPlace;
  final String? deathPlace;
  final List<String> patronages;
  final String? canonizationDate;
  final String? canonizedBy;
  final String? imageUrl;
  final String? prayer;
  final String? prayerFr;
  final String? prayerEn;
  final String? quote;
  final String? quoteFr;
  final String? quoteEn;
  final bool isToday;
  final List<String> categories; // e.g. ["martyr", "doctor", "apostle"]

  const Saint({
    required this.id,
    required this.name,
    required this.nameFr,
    required this.nameEn,
    required this.biography,
    required this.biographyFr,
    required this.biographyEn,
    this.shortBio,
    this.shortBioFr,
    this.shortBioEn,
    this.feastDay,
    this.feastMonth,
    this.feastDayOfMonth,
    this.birthYear,
    this.deathYear,
    this.birthPlace,
    this.deathPlace,
    this.patronages = const [],
    this.canonizationDate,
    this.canonizedBy,
    this.imageUrl,
    this.prayer,
    this.prayerFr,
    this.prayerEn,
    this.quote,
    this.quoteFr,
    this.quoteEn,
    this.isToday = false,
    this.categories = const [],
  });

  String getName(String languageCode) =>
      languageCode == 'fr' ? nameFr : nameEn;

  String getBiography(String languageCode) =>
      languageCode == 'fr' ? biographyFr : biographyEn;

  String? getShortBio(String languageCode) =>
      languageCode == 'fr' ? shortBioFr : shortBioEn;

  String? getPrayer(String languageCode) =>
      languageCode == 'fr' ? prayerFr : prayerEn;

  String? getQuote(String languageCode) =>
      languageCode == 'fr' ? quoteFr : quoteEn;

  bool get isMartyr => categories.contains('martyr');
  bool get isDoctor => categories.contains('doctor');
  bool get isApostle => categories.contains('apostle');
  bool get isVirgin => categories.contains('virgin');
  bool get isPope => categories.contains('pope');

  Saint copyWith({
    String? id,
    String? name,
    String? nameFr,
    String? nameEn,
    String? biography,
    String? biographyFr,
    String? biographyEn,
    bool? isToday,
  }) {
    return Saint(
      id: id ?? this.id,
      name: name ?? this.name,
      nameFr: nameFr ?? this.nameFr,
      nameEn: nameEn ?? this.nameEn,
      biography: biography ?? this.biography,
      biographyFr: biographyFr ?? this.biographyFr,
      biographyEn: biographyEn ?? this.biographyEn,
      shortBio: shortBio,
      shortBioFr: shortBioFr,
      shortBioEn: shortBioEn,
      feastDay: feastDay,
      feastMonth: feastMonth,
      feastDayOfMonth: feastDayOfMonth,
      birthYear: birthYear,
      deathYear: deathYear,
      birthPlace: birthPlace,
      deathPlace: deathPlace,
      patronages: patronages,
      canonizationDate: canonizationDate,
      canonizedBy: canonizedBy,
      imageUrl: imageUrl,
      prayer: prayer,
      prayerFr: prayerFr,
      prayerEn: prayerEn,
      quote: quote,
      quoteFr: quoteFr,
      quoteEn: quoteEn,
      isToday: isToday ?? this.isToday,
      categories: categories,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Saint && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
