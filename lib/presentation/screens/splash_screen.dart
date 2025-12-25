import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/constants.dart';
import '../../core/services/logger_service.dart';
import '../../core/database/database_helper.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'categories_screen.dart';

/// Splash Screen - Initial loading screen
///
/// Responsibilities:
/// - Initialize database
/// - Check if data needs to be imported
/// - Navigate to appropriate screen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Initialize app
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final logger = LoggerService.instance;

    try {
      await logger.info('SplashScreen', 'Starting application initialization');

      // Step 1: Initialize logger
      await logger.initialize();
      await logger.info('SplashScreen', 'Logger initialized');

      // Step 2: Initialize database
      await logger.info('SplashScreen', 'Initializing database');
      final db = await DatabaseHelper.instance.database;
      await logger.info('SplashScreen', 'Database initialized successfully');

      // Step 3: Wait for animation to complete
      await Future.delayed(const Duration(seconds: 2));

      // Step 4: Check authentication status
      await logger.info('SplashScreen', 'Checking authentication status');
      final authState = ref.read(authProvider);
      await logger.info('SplashScreen', 'Authentication status: ${authState.isAuthenticated}');

      if (mounted) {
        // Navigate to appropriate screen
        if (authState.isAuthenticated) {
          // Already logged in, go to categories
          await logger.info('SplashScreen', 'Navigating to Categories Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const CategoriesScreen(),
            ),
          );
        } else {
          // Not logged in, go to login
          await logger.info('SplashScreen', 'Navigating to Login Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      await logger.error('SplashScreen', 'Initialization failed', e, stackTrace);
      if (mounted) {
        // On error, navigate to login
        await logger.warning('SplashScreen', 'Navigating to Login Screen due to error');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.spectrumGradient,
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon/Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowMedium,
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.engineering,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Name
                  Text(
                    Constants.appName,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                  ),

                  const SizedBox(height: 8),

                  // App Full Name
                  Text(
                    'Project Management System',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                  ),

                  const SizedBox(height: 48),

                  // Loading indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Initializing...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
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
