import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/studlok_colors.dart';
import '../../design/studlok_typography.dart';

/// A full-width, visibly curved ruler for picking a GPA target — the
/// "dream" input deliberately gets a more tactile, considered moment than
/// the plain steppers used for current GPA. Built on [ListWheelScrollView]
/// rotated 90°, which is what gives the ruler its curvature "for free"
/// (Flutter's own 3D-cylinder perspective) rather than hand-rolled
/// transforms. Fires a light haptic on every tick crossed.
class CurvedGpaPicker extends StatefulWidget {
  const CurvedGpaPicker({super.key, required this.min, required this.value, required this.onChanged});

  final double min;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<CurvedGpaPicker> createState() => _CurvedGpaPickerState();
}

class _CurvedGpaPickerState extends State<CurvedGpaPicker> {
  static const double _max = 4.0;
  static const double _tickStep = 0.1;
  static const double _itemExtent = 22;
  static const double _thickness = 180;

  late final FixedExtentScrollController _controller;
  late int _tickCount;

  @override
  void initState() {
    super.initState();
    _tickCount = _indexForValue(_max) + 1;
    _controller = FixedExtentScrollController(initialItem: _indexForValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant CurvedGpaPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.min != widget.min) {
      _tickCount = _indexForValue(_max) + 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _indexForValue(double value) => (((value - widget.min) / _tickStep).round()).clamp(0, 1 << 20);

  double _valueForIndex(int index) => (widget.min + index * _tickStep);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rulerLength = constraints.maxWidth;
        return SizedBox(
          height: 280,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned.fill(child: _AuroraGlow()),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.value.toStringAsFixed(1),
                    style: StudlokTypography.display.copyWith(color: StudlokColors.accent, fontSize: 60),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: rulerLength,
                    height: _thickness,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        SizedBox(
                          width: _thickness,
                          height: rulerLength,
                          child: Transform.rotate(
                            angle: -math.pi / 2, // turns the vertical wheel horizontal.
                            child: ListWheelScrollView.useDelegate(
                              controller: _controller,
                              itemExtent: _itemExtent,
                              diameterRatio: 1.0,
                              perspective: 0.01,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                HapticFeedback.selectionClick();
                                widget.onChanged(_valueForIndex(index));
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: _tickCount,
                                builder: (context, index) => Transform.rotate(
                                  angle: math.pi / 2, // rotates each tick back upright.
                                  child: _Tick(major: index % 5 == 0),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Fixed center pointer — the wheel scrolls under this.
                        IgnorePointer(
                          child: Container(width: 3, height: 56, color: StudlokColors.accent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick({required this.major});

  final bool major;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 2,
        height: major ? 40 : 20,
        decoration: BoxDecoration(
          color: (major ? StudlokColors.textPrimary : StudlokColors.textSecondary).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// The "dream" glow: dim, layered, wavy — a real aurora reference rather
/// than a flat radial blob — but kept within the app's single accent
/// (Color Consistency Lock), not a literal multi-hue aurora.
class _AuroraGlow extends StatefulWidget {
  const _AuroraGlow();

  @override
  State<_AuroraGlow> createState() => _AuroraGlowState();
}

class _AuroraGlowState extends State<_AuroraGlow> with SingleTickerProviderStateMixin {
  // Slow and long — a subtle drift, not an obviously-looping animation.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(painter: _AuroraWavesPainter(time: _controller.value)),
            ),
            CustomPaint(painter: _GrainPainter()),
          ],
        ),
      ),
    );
  }
}

class _AuroraWavesPainter extends CustomPainter {
  _AuroraWavesPainter({required this.time});

  /// Loops 0→1 every animation cycle.
  final double time;

  // driftSpeed shifts the wave horizontally; flickerSpeed/phase independently
  // brighten and dim each band, so the glow doesn't pulse uniformly — some
  // parts light up while others fade, like real aurora bands do.
  static const _bands = [
    (yFactor: 0.30, amplitude: 16.0, cycles: 1.4, bright: false, baseAlpha: 0.09, driftSpeed: 1.0, flickerSpeed: 1.6, phase: 0.0),
    (yFactor: 0.50, amplitude: 22.0, cycles: 1.0, bright: true, baseAlpha: 0.08, driftSpeed: -0.7, flickerSpeed: 1.1, phase: 2.1),
    (yFactor: 0.68, amplitude: 14.0, cycles: 1.8, bright: false, baseAlpha: 0.07, driftSpeed: 1.3, flickerSpeed: 0.8, phase: 4.4),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = time * 2 * math.pi;
    for (final band in _bands) {
      final driftPhase = t * band.driftSpeed;
      final flicker = 0.5 + 0.5 * math.sin(t * band.flickerSpeed + band.phase);
      final alpha = band.baseAlpha * (0.5 + flicker); // ranges roughly 0.5x-1.5x baseAlpha
      final yDrift = 0.02 * math.sin(t * band.driftSpeed * 0.6);

      final baseY = size.height * (band.yFactor + yDrift);
      final path = Path()..moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 6) {
        final y = baseY + band.amplitude * math.sin((x / size.width) * 2 * math.pi * band.cycles + driftPhase);
        path.lineTo(x, y);
      }
      final color = band.bright ? StudlokColors.accentBright : StudlokColors.accent;
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 46
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraWavesPainter oldDelegate) => oldDelegate.time != time;
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(7); // fixed seed — a static texture, not per-frame static noise.
    final paint = Paint();
    for (var i = 0; i < 260; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      paint.color = StudlokColors.textPrimary.withValues(alpha: rng.nextDouble() * 0.025);
      canvas.drawCircle(Offset(dx, dy), 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
