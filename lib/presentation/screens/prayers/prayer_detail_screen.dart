import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../domain/entities/prayer.dart';
import '../../providers/prayer_provider.dart';

class PrayerDetailScreen extends ConsumerStatefulWidget {
  final String prayerId;

  const PrayerDetailScreen({super.key, required this.prayerId});

  @override
  ConsumerState<PrayerDetailScreen> createState() =>
      _PrayerDetailScreenState();
}

class _PrayerDetailScreenState extends ConsumerState<PrayerDetailScreen> {
  Timer? _ticker;
  int _selectedMinutes = 5;

  static const _timerOptions = [3, 5, 10, 15, 20, 30];

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    ref.read(prayerTimerProvider.notifier).start(_selectedMinutes * 60);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(prayerTimerProvider.notifier).tick();
    });
  }

  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
    ref.read(prayerTimerProvider.notifier).reset();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(prayerTimerProvider);
    final (timerStatus, remainingSeconds) = timerState;
    final allPrayers = ref.watch(allPrayersProvider);

    return allPrayers.when(
      data: (prayers) {
        final prayer = prayers.cast<Prayer?>().firstWhere(
          (p) => p?.id == widget.prayerId,
          orElse: () => null,
        );

        if (prayer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Prière')),
            body: const Center(child: Text('Prière introuvable')),
          );
        }

        return _buildScreen(prayer, timerStatus, remainingSeconds);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Prière')),
        body: const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Prière')),
        body: Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildScreen(
    Prayer prayer,
    TimerState timerStatus,
    int remainingSeconds,
  ) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.liturgicalPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                prayer.getTitle('fr'),
                style: const TextStyle(
                  fontFamily: 'CrimsonText',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A0080), AppColors.liturgicalPurple],
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info
                  if (prayer.origin != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.history, size: 14, color: AppColors.mediumGray),
                        const SizedBox(width: 4),
                        Text(
                          prayer.origin!,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (prayer.estimatedDurationSeconds != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.mediumGray),
                        const SizedBox(width: 4),
                        Text(
                          '~${(prayer.estimatedDurationSeconds! / 60).ceil()} min',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Divider(),
                  const SizedBox(height: 20),

                  // Prayer text
                  Text(
                    prayer.getBody('fr'),
                    style: AppTextStyles.prayerText.copyWith(
                      fontSize: 20,
                      height: 2.0,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Timer section
                  _buildTimerSection(timerStatus, remainingSeconds),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSection(TimerState status, int remaining) {
    final isIdle = status == TimerState.idle;
    final isRunning = status == TimerState.running;
    final isCompleted = status == TimerState.completed;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(
        children: [
          Text(
            'Minuterie de prière',
            style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 16),

          if (isIdle) ...[
            // Duration selector
            Wrap(
              spacing: 8,
              children: _timerOptions.map((min) {
                final isSelected = min == _selectedMinutes;
                return ChoiceChip(
                  label: Text('$min min'),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedMinutes = min),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.primary,
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _startTimer,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Commencer la prière'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.liturgicalPurple,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else if (isRunning || status == TimerState.paused) ...[
            // Timer display
            Text(
              _formatTime(remaining),
              style: const TextStyle(
                fontFamily: 'CrimsonText',
                fontSize: 52,
                fontWeight: FontWeight.w700,
                color: AppColors.liturgicalPurple,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: AppColors.liturgicalPurple,
                  ),
                  onPressed: () {
                    if (isRunning) {
                      ref.read(prayerTimerProvider.notifier).pause();
                      _ticker?.cancel();
                    } else {
                      ref.read(prayerTimerProvider.notifier).resume();
                      _startTicker();
                    }
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.stop, size: 32, color: AppColors.error),
                  onPressed: _stopTimer,
                ),
              ],
            ),
          ] else if (isCompleted) ...[
            const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            const SizedBox(height: 8),
            const Text(
              'Prière terminée ✝',
              style: TextStyle(
                fontFamily: 'CrimsonText',
                fontSize: 22,
                color: AppColors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _stopTimer,
              child: const Text('Nouvelle session'),
            ),
          ],
        ],
      ),
    );
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      ref.read(prayerTimerProvider.notifier).tick();
    });
  }
}
