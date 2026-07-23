import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.serif(fontSize: 15)),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final Color background;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.background,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: EdgeInsets.only(
        left: 20, right: 20, bottom: 18,
        top: MediaQuery.of(context).padding.top + 14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.serif(fontSize: 19, color: Colors.white)),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: AppTextStyles.sans(fontSize: 12, color: Colors.white70)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
