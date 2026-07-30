import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/firebase_providers.dart';

/// Splash Page for Kapada Creation Admin application.
class AdminSplashPage extends ConsumerStatefulWidget {
  const AdminSplashPage({super.key});

  @override
  ConsumerState<AdminSplashPage> createState() => _AdminSplashPageState();
}

class _AdminSplashPageState extends ConsumerState<AdminSplashPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();

    _timer = Timer(const Duration(milliseconds: 4200), () {
      if (!mounted) return;
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        context.go(AppRoutes.adminHome);
      } else {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF123D2B);
    const softGold = Color(0xFFF5D061); // Bright luminous champagne gold

    return Scaffold(
      backgroundColor: deepGreen,
      body: SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Admin Logo Badge
                      Container(
                        width: 130,
                        height: 130,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Brand Title
                      Text(
                        'KAPADA CREATION',
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.background,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline
                      Text(
                        '“We care what you wear”',
                        style: GoogleFonts.montserrat(
                          color: softGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Loading progress indicator
                      const SizedBox(
                        width: 36,
                        height: 2,
                        child: LinearProgressIndicator(
                          color: softGold,
                          backgroundColor: Color(0x33FFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
  }
}
