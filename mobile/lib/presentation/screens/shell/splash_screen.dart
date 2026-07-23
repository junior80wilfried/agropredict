import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text('AgroSense', style: AppTextStyles.serif(fontSize: 28, color: Colors.white)),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
