import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class StreakDisplay extends StatelessWidget {
  final int streak;
  final bool compact;

  const StreakDisplay({
    super.key,
    required this.streak,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildFull() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF8C42),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B35).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Flame icon with animation feel
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, scale, child) => Transform.scale(
              scale: scale,
              child: child,
            ),
            child: const Text(
              '🔥',
              style: TextStyle(fontSize: 32),
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$streak',
                    style: const TextStyle(
                      fontFamily: 'CrimsonText',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'jours',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Text(
                'Série de prière en cours',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12,
                  color: Colors.white70,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Streak milestone indicator
          _StreakMilestone(streak: streak),
        ],
      ),
    );
  }

  Widget _buildCompact() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 4),
        Text(
          '$streak j',
          style: AppTextStyles.labelMedium.copyWith(
            color: const Color(0xFFFF6B35),
          ),
        ),
      ],
    );
  }
}

class _StreakMilestone extends StatelessWidget {
  final int streak;

  const _StreakMilestone({required this.streak});

  @override
  Widget build(BuildContext context) {
    final (nextMilestone, label) = _getNextMilestone();
    final progress = streak / nextMilestone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$streak / $nextMilestone',
          style: const TextStyle(
            fontFamily: 'Lato',
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  (int, String) _getNextMilestone() {
    final milestones = [7, 14, 30, 60, 100, 365];
    for (final m in milestones) {
      if (streak < m) return (m, 'Objectif : $m jours');
    }
    return (streak + 30, 'Continuez !');
  }
}
