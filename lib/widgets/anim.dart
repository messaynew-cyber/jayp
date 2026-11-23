import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme.dart';

/// Fade + rise entrance. Stagger with [delay] for list items.
class RiseIn extends StatefulWidget {
  final Widget child;
  final int delay;
  final double offset;
  const RiseIn({super.key, required this.child, this.delay = 0, this.offset = 18});

  @override
  State<RiseIn> createState() => _RiseInState();
}

class _RiseInState extends State<RiseIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fade = CurvedAnimation(parent: _c, curve: const Cubic(0.16, 1, 0.3, 1));
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offset / 100),
      end: Offset.zero,
    ).animate(_fade);
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

/// Real press physics — scales down on touch-down, springs back on release.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? radius;
  const Pressable({super.key, required this.child, this.onTap, this.radius});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapCancel: () => _c.reverse(),
      onTapUp: (_) => _c.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Animated shimmer sweep across any child — the luxury tell.
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration period;
  const Shimmer({super.key, required this.child, this.period = const Duration(seconds: 4)});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.period)..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) {
            final dx = bounds.width * (_c.value * 2.2 - 0.6);
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.transparent,
                Colors.transparent,
                Color(0x22FFFFFF),
                Color(0x55FFFFFF),
                Color(0x22FFFFFF),
                Colors.transparent,
                Colors.transparent,
              ],
              stops: const [0.0, 0.42, 0.47, 0.5, 0.53, 0.58, 1.0],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  final double dx;
  const _SlideGradient(this.dx);
  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

/// Counts a number up from 0 on first build.
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;
  const CountUp(this.value, {super.key, this.style, this.duration = const Duration(milliseconds: 900)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: const Cubic(0.16, 1, 0.3, 1),
      builder: (_, v, __) => Text(v.round().toString(), style: style),
    );
  }
}

/// Progress ring that fills from zero with a spring.
class AnimatedRing extends StatelessWidget {
  final double value;
  final double size;
  final double stroke;
  final Widget? center;
  const AnimatedRing({
    super.key,
    required this.value,
    this.size = 54,
    this.stroke = 3,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1100),
      curve: const Cubic(0.16, 1, 0.3, 1),
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: stroke,
                backgroundColor: Colors.white.withOpacity(0.06),
                valueColor: const AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            if (center != null) center!,
          ],
        ),
      ),
    );
  }
}

/// Three pulsing dots — thinking state.
class TypingDots extends StatefulWidget {
  const TypingDots({super.key});
  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final t = ((_c.value + i * 0.22) % 1.0);
          final s = 0.6 + math.sin(t * math.pi) * 0.7;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Transform.scale(
              scale: s,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Bars that grow one after another.
class AnimatedBars extends StatelessWidget {
  final List<double> values;
  final Color color;
  const AnimatedBars({super.key, required this.values, this.color = AppColors.accent});

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final span = (hi - lo) == 0 ? 1.0 : (hi - lo);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < values.length; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 8 + ((values[i] - lo) / span) * 48),
                duration: Duration(milliseconds: 380 + i * 40),
                curve: const Cubic(0.16, 1, 0.3, 1),
                builder: (_, h, __) => Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
