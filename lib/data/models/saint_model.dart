import '../../domain/entities/saint.dart';

class SaintModel extends Saint {
  const SaintModel({
    required super.id,
    required super.name,
    required super.nameFr,
    required super.nameEn,
    required super.biography,
    required super.biographyFr,
    required super.biographyEn,
    super.shortBio,
    super.shortBioFr,
    super.shortBioEn,
    super.feastDay,
    super.feastMonth,
    super.feastDayOfMonth,
    super.birthYear,
    super.deathYear,
    super.birthPlace,
    super.deathPlace,
    super.patronages,
    super.canonizationDate,
    super.canonizedBy,
    super.imageUrl,
    super.prayer,
    super.prayerFr,
    super.prayerEn,
    super.quote,
    super.quoteFr,
    super.quoteEn,
    super.isToday,
    super.categories,
  });

  factory SaintModel.fromJson(Map<String, dynamic> json) {
    DateTime? feastDay;
    if (json['feastDay'] != null) {
      feastDay = DateTime.tryParse(json['feastDay'] as String);
    }

    return SaintModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['nameFr'] as String? ?? '',
      nameFr: json['nameFr'] as String? ?? json['name'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? json['name'] as String? ?? '',
      biography:
          json['biography'] as String? ?? json['biographyFr'] as String? ?? '',
      biographyFr: json['biographyFr'] as String? ??
          json['biography'] as String? ?? '',
      biographyEn: json['biographyEn'] as String? ??
          json['biography'] as String? ?? '',
      shortBio: json['shortBio'] as String?,
      shortBioFr: json['shortBioFr'] as String?,
      shortBioEn: json['shortBioEn'] as String?,
      feastDay: feastDay,
      feastMonth: (json['feastMonth'] as num?)?.toInt(),
      feastDayOfMonth: (json['feastDayOfMonth'] as num?)?.toInt(),
      birthYear: json['birthYear'] as String?,
      deathYear: json['deathYear'] as String?,
      birthPlace: json['birthPlace'] as String?,
      deathPlace: json['deathPlace'] as String?,
      patronages: (json['patronages'] as List<dynamic>?)
              ?.map((p) => p as String)
              .toList() ??
          const [],
      canonizationDate: json['canonizationDate'] as String?,
      canonizedBy: json['canonizedBy'] as String?,
      imageUrl: json['imageUrl'] as String?,
      prayer: json['prayer'] as String?,
      prayerFr: json['prayerFr'] as String?,
      prayerEn: json['prayerEn'] as String?,
      quote: json['quote'] as String?,
      quoteFr: json['quoteFr'] as String?,
      quoteEn: json['quoteEn'] as String?,
      isToday: json['isToday'] as bool? ?? false,
      categories: (json['categories'] as List<dynamic>?)
              ?.map((c) => c as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameFr': nameFr,
      'nameEn': nameEn,
      'biography': biography,
      'biographyFr': biographyFr,
      'biographyEn': biographyEn,
      'shortBio': shortBio,
      'shortBioFr': shortBioFr,
      'shortBioEn': shortBioEn,
      'feastDay': feastDay?.toIso8601String(),
      'feastMonth': feastMonth,
      'feastDayOfMonth': feastDayOfMonth,
      'birthYear': birthYear,
      'deathYear': deathYear,
      'birthPlace': birthPlace,
      'deathPlace': deathPlace,
      'patronages': patronages,
      'canonizationDate': canonizationDate,
      'canonizedBy': canonizedBy,
      'imageUrl': imageUrl,
      'prayer': prayer,
      'prayerFr': prayerFr,
      'prayerEn': prayerEn,
      'quote': quote,
      'quoteFr': quoteFr,
      'quoteEn': quoteEn,
      'isToday': isToday,
      'categories': categories,
    };
  }

  factory SaintModel.fromEntity(Saint saint) {
    return SaintModel(
      id: saint.id,
      name: saint.name,
      nameFr: saint.nameFr,
      nameEn: saint.nameEn,
      biography: saint.biography,
      biographyFr: saint.biographyFr,
      biographyEn: saint.biographyEn,
      shortBio: saint.shortBio,
      shortBioFr: saint.shortBioFr,
      shortBioEn: saint.shortBioEn,
      feastDay: saint.feastDay,
      feastMonth: saint.feastMonth,
      feastDayOfMonth: saint.feastDayOfMonth,
      birthYear: saint.birthYear,
      deathYear: saint.deathYear,
      birthPlace: saint.birthPlace,
      deathPlace: saint.deathPlace,
      patronages: saint.patronages,
      canonizationDate: saint.canonizationDate,
      canonizedBy: saint.canonizedBy,
      imageUrl: saint.imageUrl,
      prayer: saint.prayer,
      prayerFr: saint.prayerFr,
      prayerEn: saint.prayerEn,
      quote: saint.quote,
      quoteFr: saint.quoteFr,
      quoteEn: saint.quoteEn,
      isToday: saint.isToday,
      categories: saint.categories,
    );
  }
}
