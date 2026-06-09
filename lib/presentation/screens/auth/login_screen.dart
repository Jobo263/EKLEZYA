import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isEmailMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(userProfileProvider.notifier).signInWithGoogle();
    _handleAuthResult();
  }

  Future<void> _signInWithApple() async {
    await ref.read(userProfileProvider.notifier).signInWithApple();
    _handleAuthResult();
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;
    await ref
        .read(userProfileProvider.notifier)
        .signInWithEmail(email, password);
    _handleAuthResult();
  }

  void _handleAuthResult() {
    final profile = ref.read(userProfileProvider);
    if (profile.hasValue && profile.value != null && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    final isLoading = profileState.isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF243860)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 1.5),
                    color: AppColors.accent.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.church,
                    color: AppColors.accent,
                    size: 42,
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'EKLEZYA',
                  style: TextStyle(
                    fontFamily: 'CrimsonText',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: 6,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Votre compagnon spirituel catholique',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 13,
                    color: AppColors.lightGray,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 60),

                if (!_isEmailMode) ...[
                  // Google Sign In
                  _SocialButton(
                    onPressed: isLoading ? null : _signInWithGoogle,
                    icon: Icons.g_mobiledata,
                    label: 'Continuer avec Google',
                    backgroundColor: Colors.white,
                    textColor: AppColors.darkGray,
                    iconColor: Colors.red,
                  ),

                  const SizedBox(height: 14),

                  // Apple Sign In
                  _SocialButton(
                    onPressed: isLoading ? null : _signInWithApple,
                    icon: Icons.apple,
                    label: 'Continuer avec Apple',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    iconColor: Colors.white,
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: AppColors.primaryLight, thickness: 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: AppColors.lightGray.withOpacity(0.7),
                            fontFamily: 'Lato',
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: AppColors.primaryLight, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Email button
                  _SocialButton(
                    onPressed: () => setState(() => _isEmailMode = true),
                    icon: Icons.email_outlined,
                    label: 'Continuer avec l\'email',
                    backgroundColor: AppColors.primaryLight,
                    textColor: AppColors.white,
                    iconColor: AppColors.accent,
                  ),
                ] else ...[
                  // Email form
                  _buildEmailForm(isLoading),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => setState(() => _isEmailMode = false),
                    child: const Text(
                      '← Retour aux autres options',
                      style: TextStyle(color: AppColors.lightGray, fontFamily: 'Lato'),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Error display
                if (profileState.hasError) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.5)),
                    ),
                    child: Text(
                      profileState.error.toString().replaceAll('Exception:', '').trim(),
                      style: const TextStyle(
                        color: Color(0xFFFF8A80),
                        fontFamily: 'Lato',
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (isLoading)
                  const CircularProgressIndicator(color: AppColors.accent),

                const SizedBox(height: 40),

                // Terms
                const Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 11,
                    color: AppColors.mediumGray,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm(bool isLoading) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppColors.offWhite, fontFamily: 'Lato'),
          decoration: InputDecoration(
            labelText: 'Adresse email',
            labelStyle: const TextStyle(color: AppColors.lightGray),
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.accent),
            filled: true,
            fillColor: AppColors.primaryLight.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: const TextStyle(color: AppColors.offWhite, fontFamily: 'Lato'),
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            labelStyle: const TextStyle(color: AppColors.lightGray),
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.accent),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.lightGray,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: AppColors.primaryLight.withOpacity(0.3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isLoading ? null : _signInWithEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 22),
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
