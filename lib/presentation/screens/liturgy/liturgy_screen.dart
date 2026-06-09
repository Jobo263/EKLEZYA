import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/liturgy_calculator.dart';
import '../../../domain/entities/liturgical_day.dart';
import '../../providers/liturgy_provider.dart';
import '../../widgets/liturgical_color_badge.dart';

class LiturgyScreen extends ConsumerStatefulWidget {
  const LiturgyScreen({super.key});

  @override
  ConsumerState<LiturgyScreen> createState() => _LiturgyScreenState();
}

class _LiturgyScreenState extends ConsumerState<LiturgyScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final monthKey = (_focusedDay.year, _focusedDay.month);
    final monthMapAsync = ref.watch(liturgicalMonthMapProvider(monthKey));
    final selectedDayAsync = ref.watch(selectedDayInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Liturgie'),
      ),
      body: Column(
        children: [
          // ── Calendar ─────────────────────────────────────────────────
          monthMapAsync.when(
            data: (monthMap) => _buildCalendar(monthMap),
            loading: () => const SizedBox(
              height: 360,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (_, __) => _buildCalendar({}),
          ),

          const Divider(height: 1),

          // ── Selected day detail ───────────────────────────────────────
          Expanded(
            child: selectedDayAsync.when(
              data: (day) => _buildDayDetail(day),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar(Map<DateTime, LiturgicalDay> monthMap) {
    return TableCalendar(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        ref.read(selectedLiturgicalDateProvider.notifier).state = selected;
      },
      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
      },
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(
          fontFamily: 'Lato',
          color: AppColors.primary,
        ),
        weekendTextStyle: const TextStyle(
          fontFamily: 'Lato',
          color: AppColors.liturgicalRed,
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontFamily: 'CrimsonText',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
        rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.mediumGray,
        ),
        weekendStyle: TextStyle(
          fontFamily: 'Lato',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.liturgicalRed,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final liturgicalDay = monthMap[DateTime(day.year, day.month, day.day)];
          if (liturgicalDay == null) return null;
          final color =
              AppColors.liturgicalColorFromSeason(liturgicalDay.seasonKey);
          return _CalendarDayCell(
            day: day,
            color: color,
            isSolemnity: liturgicalDay.rank == CelebrationRank.solemnity,
            isHolyDay: liturgicalDay.isHolyDay,
          );
        },
      ),
    );
  }

  Widget _buildDayDetail(LiturgicalDay day) {
    final dateStr = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(day.date);
    final color =
        AppColors.liturgicalColorFromSeason(day.seasonKey);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr.substring(0, 1).toUpperCase() +
                          dateStr.substring(1),
                      style: AppTextStyles.titleMedium,
                    ),
                    if (day.weekOfSeason != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        '${day.seasonName} — Semaine ${day.weekOfSeason}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.mediumGray),
                      ),
                    ],
                  ],
                ),
              ),
              // Color dot
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withOpacity(0.4), blurRadius: 6),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          LiturgicalColorBadge(
            colorName: day.colorName,
            seasonName: day.seasonName,
            celebrationName: day.celebrationName,
            seasonKey: day.seasonKey,
          ),

          if (day.celebrationName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    day.rank == CelebrationRank.solemnity
                        ? Icons.star
                        : Icons.star_border,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      day.celebrationName!,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (day.isHolyDay) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '✝ Jour de précepte',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentDark,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Readings section
          if (day.readings.isNotEmpty) ...[
            Text(
              'LECTURES DU JOUR',
              style: AppTextStyles.liturgicalLabel,
            ),
            const SizedBox(height: 12),
            ...day.readings.map((r) => _ReadingCard(reading: r)),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book_outlined,
                      color: AppColors.mediumGray, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Les lectures seront disponibles\nprochainement.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime day;
  final Color color;
  final bool isSolemnity;
  final bool isHolyDay;

  const _CalendarDayCell({
    required this.day,
    required this.color,
    required this.isSolemnity,
    required this.isHolyDay,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isSolemnity
                ? Border.all(color: color, width: 1.5)
                : null,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 14,
                color: color == AppColors.liturgicalWhite
                    ? AppColors.primary
                    : color,
                fontWeight:
                    isSolemnity ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
        if (isHolyDay)
          Positioned(
            bottom: 2,
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final LiturgicalReading reading;

  const _ReadingCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reading.title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(reading.reference, style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Text(
            reading.text,
            style: AppTextStyles.prayerText.copyWith(fontSize: 16),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Lire la suite →',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 13,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
