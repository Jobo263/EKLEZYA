import 'package:flutter/foundation.dart';
import '../../core/utils/liturgy_calculator.dart';

@immutable
class LiturgicalReading {
  final String title;
  final String reference;
  final String text;
  final String type; // 'first', 'psalm', 'second', 'gospel', 'alleluia'

  const LiturgicalReading({
    required this.title,
    required this.reference,
    required this.text,
    required this.type,
  });
}

@immutable
class LiturgicalDay {
  final DateTime date;
  final LiturgicalSeason season;
  final String seasonName;
  final LiturgicalColor color;
  final String colorName;
  final String? celebrationName;
  final CelebrationRank rank;
  final int? weekOfSeason;
  final String weekdayName;
  final bool isSunday;
  final bool isHolyDay;
  final List<LiturgicalReading> readings;
  final String? massIntro;
  final String? collect;

  const LiturgicalDay({
    required this.date,
    required this.season,
    required this.seasonName,
    required this.color,
    required this.colorName,
    this.celebrationName,
    required this.rank,
    this.weekOfSeason,
    required this.weekdayName,
    required this.isSunday,
    required this.isHolyDay,
    this.readings = const [],
    this.massIntro,
    this.collect,
  });

  /// Constructs from calculator info.
  factory LiturgicalDay.fromInfo(LiturgicalDayInfo info) {
    return LiturgicalDay(
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

  /// Liturgical season key for color lookup.
  String get seasonKey => LiturgyCalculator.seasonKey(season);

  LiturgicalDay copyWith({
    List<LiturgicalReading>? readings,
    String? massIntro,
    String? collect,
  }) {
    return LiturgicalDay(
      date: date,
      season: season,
      seasonName: seasonName,
      color: color,
      colorName: colorName,
      celebrationName: celebrationName,
      rank: rank,
      weekOfSeason: weekOfSeason,
      weekdayName: weekdayName,
      isSunday: isSunday,
      isHolyDay: isHolyDay,
      readings: readings ?? this.readings,
      massIntro: massIntro ?? this.massIntro,
      collect: collect ?? this.collect,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiturgicalDay &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
