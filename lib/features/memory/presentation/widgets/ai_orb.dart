import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/space_colors.dart';

enum OrbState { idle, listening, processing, speaking }

class AIOrb extends StatefulWidget {
  final OrbState state;
  final VoidCallback? onTap;

  const AIOrb({
    super.key,
    this.state = OrbState.idle,
    this.onTap,
  });

  @override
  State<AIOrb> createState() => _AIOrbState();
}

class _AIOrbState extends State<AIOrb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getOrbColor() {
    switch (widget.state) {
      case OrbState.idle:
        return SpaceColors.neonCyan;
      case OrbState.listening:
        return SpaceColors.electricPurple;
      case OrbState.processing:
        return Colors.amber;
      case OrbState.speaking:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orbColor = _getOrbColor();
    
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Pulse Ring 2
                Container(
                  width: 140 + 10 * math.sin(_controller.value * 2 * math.pi),
                  height: 140 + 10 * math.sin(_controller.value * 2 * math.pi),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: orbColor.withOpacity(0.15),
                      width: 2,
                    ),
                  ),
                ),
                // Outer Pulse Ring 1
                Container(
                  width: 120 + 8 * math.cos(_controller.value * 2 * math.pi),
                  height: 120 + 8 * math.cos(_controller.value * 2 * math.pi),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: orbColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                ),
                // Core glowing orb
                CustomPaint(
                  painter: _OrbNeuralPainter(
                    animationValue: _controller.value,
                    orbColor: orbColor,
                    state: widget.state,
                  ),
                  size: const Size(100, 100),
                ),
                // Core center icon / logo
                Icon(
                  widget.state == OrbState.listening
                      ? Icons.mic
                      : widget.state == OrbState.processing
                          ? Icons.sync
                          : Icons.bubble_chart,
                  color: Colors.white,
                  size: 36,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrbNeuralPainter extends CustomPainter {
  final double animationValue;
  final Color orbColor;
  final OrbState state;

  _OrbNeuralPainter({
    required this.animationValue,
    required this.orbColor,
    required this.state,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 2;

    // 1. Draw glowing background radial gradient
    final radialPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          orbColor.withOpacity(0.8),
          orbColor.withOpacity(0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius * 1.5));
    canvas.drawCircle(center, baseRadius * 1.5, radialPaint);

    // 2. Draw neural node network vertices
    final int nodeCount = state == OrbState.processing ? 12 : 8;
    final double rotationOffset = animationValue * 2 * math.pi;
    final List<Offset> nodes = [];

    final nodePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodeCount; i++) {
      double angle = (i * 2 * math.pi / nodeCount) + rotationOffset;
      // Add perturbation based on sine waves
      double wiggle = 6 * math.sin(animationValue * 4 * math.pi + i);
      double r = baseRadius * 0.9 + wiggle;
      
      double x = center.dx + r * math.cos(angle);
      double y = center.dy + r * math.sin(angle);
      
      final nodePos = Offset(x, y);
      nodes.add(nodePos);
      canvas.drawCircle(nodePos, 3, nodePaint);
    }

    // Connect node vertices with fine neural filaments
    final linePaint = Paint()
      ..color = orbColor.withOpacity(0.4)
      ..strokeWidth = 1.0;

    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        // Only connect neighbors to maintain organic neural look
        int distance = (i - j).abs();
        if (distance == 1 || distance == nodes.length - 1 || (state == OrbState.processing && distance <= 2)) {
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // 3. Draw Core Circle
    final corePaint = Paint()
      ..color = SpaceColors.spaceBlack
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, baseRadius * 0.65, corePaint);

    final coreBorderPaint = Paint()
      ..color = orbColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, baseRadius * 0.65, coreBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbNeuralPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.orbColor != orbColor ||
        oldDelegate.state != state;
  }
}
