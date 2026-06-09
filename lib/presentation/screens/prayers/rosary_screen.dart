import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/prayer_provider.dart';

class RosaryScreen extends ConsumerWidget {
  const RosaryScreen({super.key});

  static const _mysteries = {
    RosaryMystery.joyful: _MysteryData(
      name: 'Mystères Joyeux',
      subtitle: 'Lundi & Samedi',
      color: Color(0xFF1565C0),
      titles: [
        'L\'Annonciation',
        'La Visitation',
        'La Nativité',
        'La Présentation de Jésus',
        'Le Recouvrement de Jésus',
      ],
      meditations: [
        'L\'Ange Gabriel annonce à Marie qu\'elle sera la Mère du Fils de Dieu.',
        'Marie rend visite à Élisabeth et proclame son Magnificat.',
        'Jésus naît à Bethléem dans la nuit de Noël.',
        'Siméon prophétise la mission du Christ.',
        'Jésus est retrouvé dans le Temple parmi les docteurs.',
      ],
    ),
    RosaryMystery.sorrowful: _MysteryData(
      name: 'Mystères Douloureux',
      subtitle: 'Mardi & Vendredi',
      color: Color(0xFF6A1B9A),
      titles: [
        'L\'Agonie au Jardin',
        'La Flagellation',
        'Le Couronnement d\'Épines',
        'Le Portement de la Croix',
        'La Crucifixion',
      ],
      meditations: [
        'Jésus prie dans l\'angoisse à Gethsémani.',
        'Jésus est attaché à la colonne et flagellé.',
        'Les soldats couronnent Jésus d\'épines.',
        'Jésus porte sa croix vers le Calvaire.',
        'Jésus est crucifié et meurt pour nos péchés.',
      ],
    ),
    RosaryMystery.glorious: _MysteryData(
      name: 'Mystères Glorieux',
      subtitle: 'Mercredi & Dimanche',
      color: Color(0xFFC9A84C),
      titles: [
        'La Résurrection',
        'L\'Ascension',
        'La Pentecôte',
        'L\'Assomption de Marie',
        'Le Couronnement de Marie',
      ],
      meditations: [
        'Jésus ressuscite glorieux d\'entre les morts.',
        'Jésus monte au Ciel quarante jours après Pâques.',
        'L\'Esprit Saint descend sur les Apôtres.',
        'Marie est élevée corps et âme dans la gloire céleste.',
        'Marie est couronnée Reine du Ciel et de la Terre.',
      ],
    ),
    RosaryMystery.luminous: _MysteryData(
      name: 'Mystères Lumineux',
      subtitle: 'Jeudi',
      color: Color(0xFF00897B),
      titles: [
        'Le Baptême au Jourdain',
        'Les Noces de Cana',
        'La Proclamation du Royaume',
        'La Transfiguration',
        'L\'Institution de l\'Eucharistie',
      ],
      meditations: [
        'Jésus est baptisé dans le Jourdain par Jean-Baptiste.',
        'À Cana, Jésus change l\'eau en vin sur l\'intercession de Marie.',
        'Jésus proclame le Royaume de Dieu et appelle à la conversion.',
        'Jésus se transfigure sur le mont Thabor.',
        'Jésus institue l\'Eucharistie lors de la Cène.',
      ],
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (mystery, decade, bead) = ref.watch(rosaryProvider);
    final mysteryData = _mysteries[mystery]!;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Le Chapelet'),
        actions: [
          PopupMenuButton<RosaryMystery>(
            icon: const Icon(Icons.swap_horiz),
            onSelected: (m) =>
                ref.read(rosaryProvider.notifier).setMystery(m),
            itemBuilder: (_) => RosaryMystery.values
                .map((m) => PopupMenuItem(
                      value: m,
                      child: Text(_mysteries[m]!.name),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mystery banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: mysteryData.color.withOpacity(0.15),
              border: Border(
                bottom: BorderSide(
                  color: mysteryData.color.withOpacity(0.3),
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  mysteryData.name,
                  style: const TextStyle(
                    fontFamily: 'CrimsonText',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.offWhite,
                  ),
                ),
                Text(
                  mysteryData.subtitle,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 12,
                    color: AppColors.lightGray,
                  ),
                ),
              ],
            ),
          ),

          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Decades
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => Container(
                      width: i + 1 == decade ? 32 : 20,
                      height: i + 1 == decade ? 32 : 20,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i + 1 < decade
                            ? mysteryData.color
                            : i + 1 == decade
                                ? mysteryData.color.withOpacity(0.8)
                                : AppColors.darkCard,
                        border: Border.all(
                          color: mysteryData.color.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: i + 1 == decade ? 14 : 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Beads progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    10,
                    (i) => Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < bead
                            ? mysteryData.color
                            : AppColors.darkCard,
                        border: Border.all(
                          color: mysteryData.color.withOpacity(0.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Current mystery meditation
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mystery title
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: mysteryData.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${decade}ème mystère',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: mysteryData.color,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    mysteryData.titles[decade - 1],
                    style: const TextStyle(
                      fontFamily: 'CrimsonText',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.offWhite,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    mysteryData.meditations[decade - 1],
                    style: const TextStyle(
                      fontFamily: 'CrimsonText',
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: AppColors.lightGray,
                      height: 1.7,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Current prayer
                  Text(
                    bead == 0
                        ? 'Récitez le Notre Père'
                        : 'Je vous salue Marie (grain $bead/10)',
                    style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: mysteryData.color,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.read(rosaryProvider.notifier).previousBead(),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Précédent'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.lightGray,
                      side: const BorderSide(color: AppColors.darkDivider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(rosaryProvider.notifier).nextBead(),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(bead == 10 && decade < 5
                        ? 'Prochain mystère'
                        : 'Suivant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mysteryData.color,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MysteryData {
  final String name;
  final String subtitle;
  final Color color;
  final List<String> titles;
  final List<String> meditations;

  const _MysteryData({
    required this.name,
    required this.subtitle,
    required this.color,
    required this.titles,
    required this.meditations,
  });
}
