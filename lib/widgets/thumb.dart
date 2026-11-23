import 'package:flutter/material.dart';
import '../theme.dart';

/// Episode thumbnail with graceful fallback when the asset is missing.
class Thumb extends StatelessWidget {
  final String? path;
  final double? width;
  final double height;
  final double radius;
  final String? category;
  const Thumb({
    super.key,
    required this.path,
    this.width,
    this.height = 64,
    this.radius = 3,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? (height * 16 / 9);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: w,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceHi),
            if (path != null && path!.isNotEmpty)
              Image.asset(
                path!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _fallback(),
              )
            else
              _fallback(),
            // bottom scrim so any overlay text stays readable
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.ground.withOpacity(0.55),
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),
            // play affordance
            Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ground.withOpacity(0.55),
                  border: Border.all(color: AppColors.accent.withOpacity(0.6)),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 16, color: AppColors.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surfaceHi,
              AppColors.accent.withOpacity(0.10),
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          (category ?? 'ጄ').toUpperCase(),
          style: kMono.copyWith(fontSize: 9, color: AppColors.accent),
        ),
      );
}
