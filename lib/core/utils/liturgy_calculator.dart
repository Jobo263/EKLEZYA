/// EKLEZYA Liturgical Calendar Calculator
///
/// Implements the Meeus/Jones/Butcher algorithm for Easter date calculation
/// and derives all movable feasts and liturgical seasons from it.
library liturgy_calculator;

/// Represents a liturgical season.
enum LiturgicalSeason {
  advent,
  christmas,
  ordinaryTimeI, // Between Baptism of Lord and Ash Wednesday
  lent,
  holyWeek,
  easterTriduum,
  easter,
  ordinaryTimeII, // After Pentecost until Advent
}

/// Liturgical vestment color.
enum LiturgicalColor {
  green,
  purple,
  white,
  red,
  rose,
  black,
  gold,
}

/// Rank of a celebration in the liturgical calendar.
enum CelebrationRank {
  solemnity,
  feast,
  obligatoryMemorial,
  optionalMemorial,
  feria,
}

/// Describes a specific liturgical day.
class LiturgicalDayInfo {
  final DateTime date;
  final LiturgicalSeason season;
  final LiturgicalColor color;
  final String seasonName;
  final String? celebrationName;
  final CelebrationRank rank;
  final int? weekOfSeason;
  final String weekdayName;
  final bool isSunday;
  final bool isHolyDay;

  const LiturgicalDayInfo({
    required this.date,
    required this.season,
    required this.color,
    required this.seasonName,
    this.celebrationName,
    required this.rank,
    this.weekOfSeason,
    required this.weekdayName,
    required this.isSunday,
    required this.isHolyDay,
  });
}

/// Holds all movable feasts for a given year.
class MovableFeasts {
  final DateTime easter;
  final DateTime ashWednesday;
  final DateTime palmSunday;
  final DateTime holyThursday;
  final DateTime goodFriday;
  final DateTime holySaturday;
  final DateTime divineMercySunday;
  final DateTime ascension;
  final DateTime pentecost;
  final DateTime trinitySunday;
  final DateTime corpusChristi;
  final DateTime sacredHeart;
  final DateTime christTheKing;
  final DateTime firstSundayOfAdvent;
  final DateTime immaculateHeart;
  final DateTime gaudeteSunday;
  final DateTime laetareSunday;

  const MovableFeasts({
    required this.easter,
    required this.ashWednesday,
    required this.palmSunday,
    required this.holyThursday,
    required this.goodFriday,
    required this.holySaturday,
    required this.divineMercySunday,
    required this.ascension,
    required this.pentecost,
    required this.trinitySunday,
    required this.corpusChristi,
    required this.sacredHeart,
    required this.christTheKing,
    required this.firstSundayOfAdvent,
    required this.immaculateHeart,
    required this.gaudeteSunday,
    required this.laetareSunday,
  });
}

class LiturgyCalculator {
  LiturgyCalculator._();

  // ── Easter: Meeus/Jones/Butcher Algorithm ─────────────────────────────────
  /// Calculates the date of Easter Sunday for the given [year]
  /// using the Meeus/Jones/Butcher algorithm (Gregorian calendar).
  ///
  /// Reference: Jean Meeus, "Astronomical Algorithms", 2nd ed., chapter 9.
  static DateTime calculateEaster(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  /// Calculates all movable feasts for the given [year].
  static MovableFeasts calculateMovableFeasts(int year) {
    final easter = calculateEaster(year);

    // Pre-Easter
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final palmSunday = easter.subtract(const Duration(days: 7));
    final holyThursday = easter.subtract(const Duration(days: 3));
    final goodFriday = easter.subtract(const Duration(days: 2));
    final holySaturday = easter.subtract(const Duration(days: 1));
    // 4th Sunday of Lent = Laetare (21 days before Easter)
    final laetareSunday = easter.subtract(const Duration(days: 21));

    // Post-Easter
    final divineMercySunday = easter.add(const Duration(days: 7));
    // Ascension: 40 days after Easter (counting Easter as day 1) = +39 days
    final ascension = easter.add(const Duration(days: 39));
    // Pentecost: 50 days after Easter (counting Easter as day 1) = +49 days
    final pentecost = easter.add(const Duration(days: 49));
    final trinitySunday = easter.add(const Duration(days: 56));
    // Corpus Christi: Thursday after Trinity Sunday = +60 days
    final corpusChristi = easter.add(const Duration(days: 60));
    // Sacred Heart: Friday after Corpus Christi = +68 days
    final sacredHeart = easter.add(const Duration(days: 68));
    // Immaculate Heart: Saturday after Corpus Christi = +69 days
    final immaculateHeart = easter.add(const Duration(days: 69));

    // Christ the King: last Sunday of Ordinary Time (Sunday before Advent)
    final firstAdvent = _firstSundayOfAdvent(year);
    final christTheKing = firstAdvent.subtract(const Duration(days: 7));

    // Gaudete Sunday: 3rd Sunday of Advent
    final gaudeteSunday = firstAdvent.add(const Duration(days: 14));

    return MovableFeasts(
      easter: easter,
      ashWednesday: ashWednesday,
      palmSunday: palmSunday,
      holyThursday: holyThursday,
      goodFriday: goodFriday,
      holySaturday: holySaturday,
      divineMercySunday: divineMercySunday,
      ascension: ascension,
      pentecost: pentecost,
      trinitySunday: trinitySunday,
      corpusChristi: corpusChristi,
      sacredHeart: sacredHeart,
      christTheKing: christTheKing,
      firstSundayOfAdvent: firstAdvent,
      immaculateHeart: immaculateHeart,
      gaudeteSunday: gaudeteSunday,
      laetareSunday: laetareSunday,
    );
  }

  /// Returns the First Sunday of Advent for the given [year].
  /// Advent begins on the Sunday nearest to November 30 (St. Andrew's Day).
  static DateTime _firstSundayOfAdvent(int year) {
    final nov30 = DateTime(year, 11, 30);
    final dow = nov30.weekday; // 1=Monday … 7=Sunday
    // Distance to previous Sunday
    final daysSinceSunday = dow % 7; // Sunday → 0, Mon → 1, … Sat → 6
    // Distance to next Sunday
    final daysToNextSunday = daysSinceSunday == 0 ? 0 : 7 - daysSinceSunday;

    // Nearest Sunday
    if (daysSinceSunday <= daysToNextSunday) {
      return nov30.subtract(Duration(days: daysSinceSunday));
    } else {
      return nov30.add(Duration(days: daysToNextSunday));
    }
  }

  // ── Season determination ──────────────────────────────────────────────────

  /// Returns the [LiturgicalDayInfo] for the given [date].
  static LiturgicalDayInfo getDayInfo(DateTime date) {
    final year = date.year;
    final feasts = calculateMovableFeasts(year);
    final prevFeasts = calculateMovableFeasts(year - 1);

    final d = _dateOnly(date);

    final season = _getSeason(d, feasts, prevFeasts, year);
    final color = _getColor(d, season, feasts);
    final celebration = _getCelebration(d, feasts, year);
    final rank = celebration != null
        ? _getCelebrationRank(d, feasts, year)
        : CelebrationRank.feria;
    final weekOfSeason = _getWeekOfSeason(d, season, feasts, year);
    final isSunday = d.weekday == DateTime.sunday;
    final isHolyDay = _isHolyDayOfObligation(d, year, feasts);

    return LiturgicalDayInfo(
      date: d,
      season: season,
      color: color,
      seasonName: _seasonName(season),
      celebrationName: celebration,
      rank: rank,
      weekOfSeason: weekOfSeason,
      weekdayName: _weekdayName(d.weekday),
      isSunday: isSunday,
      isHolyDay: isHolyDay,
    );
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool _isInRange(DateTime d, DateTime start, DateTime end) =>
      !d.isBefore(start) && !d.isAfter(end);

  static LiturgicalSeason _getSeason(
    DateTime d,
    MovableFeasts f,
    MovableFeasts prevF,
    int year,
  ) {
    // ── Advent (current year) ────────────────────────────────────────────
    final adventEnd = DateTime(year, 12, 24);
    if (_isInRange(d, f.firstSundayOfAdvent, adventEnd)) {
      return LiturgicalSeason.advent;
    }

    // ── Christmas: Dec 25 → Baptism of the Lord ──────────────────────────
    // Check if we're in last year's Christmas season
    final baptismThisYear = baptismOfLord(year);
    if (_isInRange(d, DateTime(year - 1, 12, 25), baptismThisYear)) {
      return LiturgicalSeason.christmas;
    }
    // This year's Christmas (Dec 25–31)
    if (_isInRange(d, DateTime(year, 12, 25), DateTime(year, 12, 31))) {
      return LiturgicalSeason.christmas;
    }

    // ── Holy Triduum (overrides Holy Week) ───────────────────────────────
    if (_sameDay(d, f.holyThursday) ||
        _sameDay(d, f.goodFriday) ||
        _sameDay(d, f.holySaturday)) {
      return LiturgicalSeason.easterTriduum;
    }

    // ── Holy Week ────────────────────────────────────────────────────────
    if (_isInRange(d, f.palmSunday, f.holySaturday)) {
      return LiturgicalSeason.holyWeek;
    }

    // ── Easter (Easter Sunday → Pentecost) ───────────────────────────────
    if (_isInRange(d, f.easter, f.pentecost)) {
      return LiturgicalSeason.easter;
    }

    // ── Lent (Ash Wednesday → Palm Sunday - 1) ───────────────────────────
    if (_isInRange(
        d, f.ashWednesday, f.palmSunday.subtract(const Duration(days: 1)))) {
      return LiturgicalSeason.lent;
    }

    // ── Ordinary Time I: Baptism of Lord + 1 → Ash Wednesday - 1 ────────
    final otIStart = baptismThisYear.add(const Duration(days: 1));
    final otIEnd = f.ashWednesday.subtract(const Duration(days: 1));
    if (_isInRange(d, otIStart, otIEnd)) {
      return LiturgicalSeason.ordinaryTimeI;
    }

    // ── Ordinary Time II: Pentecost + 1 → Advent - 1 ────────────────────
    final otIIStart = f.pentecost.add(const Duration(days: 1));
    final otIIEnd = f.firstSundayOfAdvent.subtract(const Duration(days: 1));
    if (_isInRange(d, otIIStart, otIIEnd)) {
      return LiturgicalSeason.ordinaryTimeII;
    }

    return LiturgicalSeason.ordinaryTimeII;
  }

  /// Baptism of the Lord: Sunday after January 6.
  /// If Epiphany (Jan 6) is already Sunday, Baptism is Monday Jan 7.
  static DateTime baptismOfLord(int year) {
    final epiphany = DateTime(year, 1, 6);
    if (epiphany.weekday == DateTime.sunday) {
      return epiphany.add(const Duration(days: 1));
    }
    final daysUntilSunday = DateTime.sunday - epiphany.weekday;
    return epiphany.add(Duration(days: daysUntilSunday));
  }

  static LiturgicalColor _getColor(
    DateTime d,
    LiturgicalSeason season,
    MovableFeasts f,
  ) {
    if (_sameDay(d, f.goodFriday)) return LiturgicalColor.red;
    if (_sameDay(d, f.palmSunday)) return LiturgicalColor.red;
    if (_sameDay(d, f.pentecost)) return LiturgicalColor.red;
    if (_sameDay(d, f.gaudeteSunday)) return LiturgicalColor.rose;
    if (_sameDay(d, f.laetareSunday)) return LiturgicalColor.rose;

    switch (season) {
      case LiturgicalSeason.advent:
        return LiturgicalColor.purple;
      case LiturgicalSeason.christmas:
        return LiturgicalColor.white;
      case LiturgicalSeason.lent:
        return LiturgicalColor.purple;
      case LiturgicalSeason.holyWeek:
        return LiturgicalColor.red;
      case LiturgicalSeason.easterTriduum:
        return LiturgicalColor.white;
      case LiturgicalSeason.easter:
        return LiturgicalColor.white;
      case LiturgicalSeason.ordinaryTimeI:
      case LiturgicalSeason.ordinaryTimeII:
        return LiturgicalColor.green;
    }
  }

  static String? _getCelebration(DateTime d, MovableFeasts f, int year) {
    if (_sameDay(d, f.easter)) return 'Résurrection du Seigneur (Pâques)';
    if (_sameDay(d, f.ashWednesday)) return 'Mercredi des Cendres';
    if (_sameDay(d, f.palmSunday)) return 'Dimanche des Rameaux';
    if (_sameDay(d, f.holyThursday)) return 'Jeudi Saint';
    if (_sameDay(d, f.goodFriday)) return 'Vendredi Saint';
    if (_sameDay(d, f.holySaturday)) return 'Samedi Saint (Vigile Pascale)';
    if (_sameDay(d, f.divineMercySunday)) return 'Dimanche de la Miséricorde Divine';
    if (_sameDay(d, f.ascension)) return 'Ascension du Seigneur';
    if (_sameDay(d, f.pentecost)) return 'Pentecôte';
    if (_sameDay(d, f.trinitySunday)) return 'Solennité de la Très Sainte Trinité';
    if (_sameDay(d, f.corpusChristi)) return 'Fête-Dieu (Corpus Christi)';
    if (_sameDay(d, f.sacredHeart)) return 'Sacré-Cœur de Jésus';
    if (_sameDay(d, f.christTheKing)) return 'Notre-Seigneur Jésus-Christ, Roi de l\'Univers';
    if (_sameDay(d, f.gaudeteSunday)) return '3ème dimanche de l\'Avent — Gaudete';
    if (_sameDay(d, f.laetareSunday)) return '4ème dimanche du Carême — Laetare';
    if (_sameDay(d, f.immaculateHeart)) return 'Cœur Immaculé de la Bienheureuse Vierge Marie';

    return _fixedFeastName((d.month, d.day));
  }

  static String? _fixedFeastName((int, int) md) {
    const Map<(int, int), String> feasts = {
      (1, 1): 'Sainte Marie, Mère de Dieu',
      (1, 6): 'Épiphanie du Seigneur',
      (2, 2): 'Présentation du Seigneur (Chandeleur)',
      (2, 22): 'Chaire de Saint Pierre',
      (3, 19): 'Saint Joseph, Époux de la Vierge Marie',
      (3, 25): 'Annonciation du Seigneur',
      (4, 23): 'Saint Georges, Martyr',
      (6, 24): 'Nativité de Saint Jean-Baptiste',
      (6, 29): 'Saints Pierre et Paul, Apôtres',
      (7, 22): 'Sainte Marie-Madeleine',
      (7, 25): 'Saint Jacques, Apôtre',
      (7, 26): 'Saints Joachim et Anne',
      (8, 6): 'Transfiguration du Seigneur',
      (8, 10): 'Saint Laurent, Diacre et Martyr',
      (8, 15): 'Assomption de la Vierge Marie',
      (8, 22): 'La Bienheureuse Vierge Marie Reine',
      (9, 8): 'Nativité de la Bienheureuse Vierge Marie',
      (9, 14): 'Exaltation de la Sainte Croix',
      (9, 29): 'Saints Michel, Gabriel et Raphaël, Archanges',
      (10, 2): 'Saints Anges Gardiens',
      (10, 4): 'Saint François d\'Assise',
      (10, 7): 'Notre-Dame du Rosaire',
      (11, 1): 'Toussaint',
      (11, 2): 'Commémoration de tous les Fidèles Défunts',
      (11, 9): 'Dédicace de la Basilique du Latran',
      (12, 8): 'Immaculée Conception de la Bienheureuse Vierge Marie',
      (12, 25): 'Nativité de Notre-Seigneur Jésus-Christ (Noël)',
      (12, 26): 'Saint Étienne, Premier Martyr',
      (12, 27): 'Saint Jean, Apôtre et Évangéliste',
      (12, 28): 'Saints Innocents, Martyrs',
      (12, 31): 'Saint Sylvestre Ier, Pape',
    };
    return feasts[md];
  }

  static CelebrationRank _getCelebrationRank(
      DateTime d, MovableFeasts f, int year) {
    final solemnities = <DateTime>{
      f.easter,
      f.pentecost,
      f.trinitySunday,
      f.corpusChristi,
      f.sacredHeart,
      f.christTheKing,
      f.ascension,
      DateTime(year, 1, 1),
      DateTime(year, 3, 19),
      DateTime(year, 3, 25),
      DateTime(year, 6, 24),
      DateTime(year, 6, 29),
      DateTime(year, 8, 15),
      DateTime(year, 11, 1),
      DateTime(year, 12, 8),
      DateTime(year, 12, 25),
    };
    for (final s in solemnities) {
      if (_sameDay(d, s)) return CelebrationRank.solemnity;
    }
    final feasts = <DateTime>{
      DateTime(year, 2, 2),
      DateTime(year, 8, 6),
      DateTime(year, 9, 14),
    };
    for (final feat in feasts) {
      if (_sameDay(d, feat)) return CelebrationRank.feast;
    }
    return CelebrationRank.obligatoryMemorial;
  }

  static int? _getWeekOfSeason(
      DateTime d, LiturgicalSeason season, MovableFeasts f, int year) {
    switch (season) {
      case LiturgicalSeason.advent:
        final diff = d.difference(f.firstSundayOfAdvent).inDays;
        return (diff ~/ 7) + 1;
      case LiturgicalSeason.lent:
        final diff = d.difference(f.ashWednesday).inDays;
        return (diff ~/ 7) + 1;
      case LiturgicalSeason.easter:
        final diff = d.difference(f.easter).inDays;
        return (diff ~/ 7) + 1;
      case LiturgicalSeason.ordinaryTimeI:
        final baptism = baptismOfLord(year);
        final diff = d.difference(baptism).inDays;
        return (diff ~/ 7) + 1;
      case LiturgicalSeason.ordinaryTimeII:
        // OT II continues numbering from where OT I left off
        final baptism = baptismOfLord(year);
        final weeksOTI =
            f.ashWednesday.difference(baptism).inDays ~/ 7;
        final diff = d.difference(f.pentecost).inDays;
        return weeksOTI + (diff ~/ 7) + 2;
      default:
        return null;
    }
  }

  static bool _isHolyDayOfObligation(
      DateTime d, int year, MovableFeasts f) {
    final md = (d.month, d.day);
    const holyDayDates = <(int, int)>{
      (1, 1),
      (1, 6),
      (3, 19),
      (8, 15),
      (11, 1),
      (12, 8),
      (12, 25),
    };
    if (holyDayDates.contains(md)) return true;
    if (_sameDay(d, f.easter)) return true;
    if (_sameDay(d, f.ascension)) return true;
    if (_sameDay(d, f.corpusChristi)) return true;
    return false;
  }

  static String _seasonName(LiturgicalSeason s) {
    switch (s) {
      case LiturgicalSeason.advent:
        return 'Avent';
      case LiturgicalSeason.christmas:
        return 'Temps de Noël';
      case LiturgicalSeason.ordinaryTimeI:
      case LiturgicalSeason.ordinaryTimeII:
        return 'Temps Ordinaire';
      case LiturgicalSeason.lent:
        return 'Carême';
      case LiturgicalSeason.holyWeek:
        return 'Semaine Sainte';
      case LiturgicalSeason.easterTriduum:
        return 'Triduum Pascal';
      case LiturgicalSeason.easter:
        return 'Temps Pascal';
    }
  }

  static String _weekdayName(int weekday) {
    const names = <int, String>{
      1: 'Lundi',
      2: 'Mardi',
      3: 'Mercredi',
      4: 'Jeudi',
      5: 'Vendredi',
      6: 'Samedi',
      7: 'Dimanche',
    };
    return names[weekday] ?? '';
  }

  /// Returns the liturgical color name in French.
  static String colorName(LiturgicalColor c) {
    switch (c) {
      case LiturgicalColor.green:
        return 'Vert';
      case LiturgicalColor.purple:
        return 'Violet';
      case LiturgicalColor.white:
        return 'Blanc';
      case LiturgicalColor.red:
        return 'Rouge';
      case LiturgicalColor.rose:
        return 'Rose';
      case LiturgicalColor.black:
        return 'Noir';
      case LiturgicalColor.gold:
        return 'Or';
    }
  }

  /// Returns the season key used by [AppColors.liturgicalColorFromSeason].
  static String seasonKey(LiturgicalSeason s) {
    switch (s) {
      case LiturgicalSeason.advent:
        return 'advent';
      case LiturgicalSeason.christmas:
        return 'christmas';
      case LiturgicalSeason.lent:
        return 'lent';
      case LiturgicalSeason.holyWeek:
        return 'holy_week';
      case LiturgicalSeason.easterTriduum:
      case LiturgicalSeason.easter:
        return 'easter';
      case LiturgicalSeason.ordinaryTimeI:
      case LiturgicalSeason.ordinaryTimeII:
        return 'ordinary_time';
    }
  }

  /// Verify Easter calculations for known years.
  /// Returns true if all assertions pass.
  static bool verifyEaster() {
    final known = <int, (int, int)>{
      2020: (4, 12),
      2021: (4, 4),
      2022: (4, 17),
      2023: (4, 9),
      2024: (3, 31),
      2025: (4, 20),
      2026: (4, 5),
      2027: (3, 28),
      2028: (4, 16),
      2029: (4, 1),
      2030: (4, 21),
    };
    for (final entry in known.entries) {
      final easter = calculateEaster(entry.key);
      final expected = entry.value;
      if (easter.month != expected.$1 || easter.day != expected.$2) {
        return false;
      }
    }
    return true;
  }
}
