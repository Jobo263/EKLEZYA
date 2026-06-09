import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';

class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Color> gradientColors;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.gradientColors,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _pages = [
    _OnboardingPage(
      title: 'Bienvenue dans EKLEZYA',
      subtitle: 'Votre compagnon spirituel catholique pour chaque jour de votre vie de foi.',
      icon: Icons.church,
      iconColor: AppColors.accent,
      gradientColors: [AppColors.primaryDark, AppColors.primary],
    ),
    _OnboardingPage(
      title: 'La Bible Complète',
      subtitle: 'Lisez, mémorisez et méditez la Parole de Dieu. Surlignez vos versets préférés et ajoutez des notes personnelles.',
      icon: Icons.menu_book,
      iconColor: Color(0xFF90CAF9),
      gradientColors: [Color(0xFF1A2740), Color(0xFF1B3060)],
    ),
    _OnboardingPage(
      title: 'Liturgie Quotidienne',
      subtitle: 'Suivez le calendrier liturgique, les couleurs et les fêtes de l\'Église catholique tout au long de l\'année.',
      icon: Icons.calendar_month,
      iconColor: AppColors.liturgicalGold,
      gradientColors: [Color(0xFF2A1A00), Color(0xFF3D2800)],
    ),
    _OnboardingPage(
      title: 'Les Saints',
      subtitle: 'Découvrez chaque jour le saint du jour, sa vie inspirante, sa spiritualité et une prière en son honneur.',
      icon: Icons.star,
      iconColor: Color(0xFFFFD54F),
      gradientColors: [Color(0xFF1A0A2E), Color(0xFF2E1040)],
    ),
    _OnboardingPage(
      title: 'IA Théologique',
      subtitle: 'Posez toutes vos questions sur la foi catholique à notre assistant IA formé à la théologie et au Magistère de l\'Église.',
      icon: Icons.psychology,
      iconColor: Color(0xFF80DEEA),
      gradientColors: [Color(0xFF001A2E), Color(0xFF002A40)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasOnboarded', true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Pages
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) {
              setState(() => _currentPage = page);
              _animController.reset();
              _animController.forward();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _buildPage(_pages[index], index),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradientColors,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Icon in circle
            FadeTransition(
              opacity: _currentPage == index ? _fadeAnim : const AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: page.iconColor.withOpacity(0.5), width: 2),
                  color: page.iconColor.withOpacity(0.1),
                ),
                child: Icon(
                  page.icon,
                  size: 72,
                  color: page.iconColor,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _currentPage == index ? _fadeAnim : const AlwaysStoppedAnimation(1.0),
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'CrimsonText',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.offWhite,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: FadeTransition(
                opacity: _currentPage == index ? _fadeAnim : const AlwaysStoppedAnimation(1.0),
                child: Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: AppColors.lightGray,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLast = _currentPage == _pages.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _currentPage ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? AppColors.accent
                      : AppColors.offWhite.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Next / Get Started button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              child: Text(
                isLast ? 'Commencer' : 'Suivant',
                style: const TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Sign in link
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text(
              'J\'ai déjà un compte',
              style: TextStyle(
                fontFamily: 'Lato',
                color: AppColors.lightGray,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
