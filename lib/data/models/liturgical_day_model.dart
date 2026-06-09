import '../../core/utils/liturgy_calculator.dart';
import '../../domain/entities/liturgical_day.dart';

class LiturgicalReadingModel extends LiturgicalReading {
  const LiturgicalReadingModel({
    required super.title,
    required super.reference,
    required super.text,
    required super.type,
  });

  factory LiturgicalReadingModel.fromJson(Map<String, dynamic> json) {
    return LiturgicalReadingModel(
      title: json['title'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? 'gospel',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'reference': reference,
      'text': text,
      'type': type,
    };
  }
}

class LiturgicalDayModel extends LiturgicalDay {
  const LiturgicalDayModel({
    required super.date,
    required super.season,
    required super.seasonName,
    required super.color,
    required super.colorName,
    super.celebrationName,
    required super.rank,
    super.weekOfSeason,
    required super.weekdayName,
    required super.isSunday,
    required super.isHolyDay,
    super.readings,
    super.massIntro,
    super.collect,
  });

  factory LiturgicalDayModel.fromInfo(LiturgicalDayInfo info) {
    return LiturgicalDayModel(
      date: info.date,
      season: info.season,
      seasonName: info.seasonName,
      color: info.color,
      colorName: LiturgyCalculator.colorName(info.color),
      celebrationName: info.celebrationName,
      rank: info.rank,
      weekOfSeason: info.weekOfSeason,
      weekdayName: info.weekdayName,
      isSunday: info.isSunday,
      isHolyDay: info.isHolyDay,
    );
  }

  factory LiturgicalDayModel.fromJson(Map<String, dynamic> json) {
    final season = LiturgicalSeason.values.firstWhere(
      (s) => s.name == json['season'] as String?,
      orElse: () => LiturgicalSeason.ordinaryTimeII,
    );
    final color = LiturgicalColor.values.firstWhere(
      (c) => c.name == json['color'] as String?,
      orElse: () => LiturgicalColor.green,
    );
    final rank = CelebrationRank.values.firstWhere(
      (r) => r.name == json['rank'] as String?,
      orElse: () => CelebrationRank.feria,
    );

    final readingsJson = json['readings'] as List<dynamic>? ?? [];

    return LiturgicalDayModel(
      date: DateTime.parse(json['date'] as String),
      season: season,
      seasonName: json['seasonName'] as String? ?? '',
      color: color,
      colorName: json['colorName'] as String? ?? '',
      celebrationName: json['celebrationName'] as String?,
      rank: rank,
      weekOfSeason: (json['weekOfSeason'] as num?)?.toInt(),
      weekdayName: json['weekdayName'] as String? ?? '',
      isSunday: json['isSunday'] as bool? ?? false,
      isHolyDay: json['isHolyDay'] as bool? ?? false,
      readings: readingsJson
          .map((r) =>
              LiturgicalReadingModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      massIntro: json['massIntro'] as String?,
      collect: json['collect'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'season': season.name,
      'seasonName': seasonName,
      'color': color.name,
      'colorName': colorName,
      'celebrationName': celebrationName,
      'rank': rank.name,
      'weekOfSeason': weekOfSeason,
      'weekdayName': weekdayName,
      'isSunday': isSunday,
      'isHolyDay': isHolyDay,
      'readings': readings
          .map((r) => LiturgicalReadingModel(
                title: r.title,
                reference: r.reference,
                text: r.text,
                type: r.type,
              ).toJson())
          .toList(),
      'massIntro': massIntro,
      'collect': collect,
    };
  }
}
