import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/space_colors.dart';
import '../../../../main.dart';
import '../widgets/ai_orb.dart';
import '../widgets/floating_add_button.dart';
import 'dump_area_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  OrbState _orbState = OrbState.idle;
  String _assistantText = "Greetings. I am your digital brain. Tap me or ask a question.";
  bool _showGalaxy = false;
  bool _showCaptureAssistant = true;

  void _triggerVoiceCommand() {
    setState(() {
      _orbState = OrbState.listening;
      _assistantText = "Listening for voice prompt...";
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _orbState = OrbState.processing;
        _assistantText = "Processing second brain query...";
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _orbState = OrbState.speaking;
          _assistantText = "Found 3 Coursera certificates in your Education vault.";
        });

        Future.delayed(const Duration(seconds: 3), () {
          setState(() {
            _orbState = OrbState.idle;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDyslexic = ref.watch(dyslexiaModeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Neural Particles Backdrop Effect
          const Positioned.fill(
            child: _NeuralBackdropPainter(),
          ),

          // 2. Main Content Canvas
          SafeArea(
            child: _showGalaxy 
                ? _build3DGalaxyView() 
                : _buildHUDDashboard(isDyslexic),
          ),

          // 3. Proactive AI Memory Capture Assistant Banner
          if (_showCaptureAssistant)
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: _buildCaptureAssistantBanner(),
            ),

          // 4. Floating Circular Add Action Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingAddButton(
              onActionSelected: (action) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: SpaceColors.midnightBlue,
                    content: Text(
                      "Capture initiated: $action. Sent to Background Queue.",
                      style: const TextStyle(color: SpaceColors.neonCyan),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUDDashboard(bool isDyslexic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 70), // Leave space for capture assistant
          
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MEMORA AI",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: SpaceColors.neonCyan,
                      letterSpacing: 2.0,
                    ),
                  ),
                  Text(
                    "SECURE DIGITAL BRAIN",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: SpaceColors.electricPurple.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: "Toggle Galaxy Map",
                    icon: const Icon(Icons.blur_circular, color: SpaceColors.neonCyan),
                    onPressed: () => setState(() => _showGalaxy = true),
                  ),
                  IconButton(
                    tooltip: "Dyslexia Mode Toggle",
                    icon: Icon(
                      isDyslexic ? Icons.font_download : Icons.font_download_outlined,
                      color: isDyslexic ? SpaceColors.neonCyan : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(dyslexiaModeProvider.notifier).state = !isDyslexic;
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),

          // Glowing AI Orb Hub
          Center(
            child: Column(
              children: [
                AIOrb(
                  state: _orbState,
                  onTap: _triggerVoiceCommand,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: SpaceColors.midnightBlue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: SpaceColors.neonCyan.withOpacity(0.2)),
                  ),
                  child: Text(
                    _assistantText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: SpaceColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Main Stats Row: Health & Storage
          Row(
            children: [
              Expanded(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "HEALTH SCORE",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SpaceColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            "87",
                            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: SpaceColors.neonCyan),
                          ),
                          Text(
                            "/100",
                            style: TextStyle(fontSize: 14, color: SpaceColors.textSecondary.withOpacity(0.7)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(
                        value: 0.87,
                        backgroundColor: SpaceColors.glassWhite,
                        valueColor: AlwaysStoppedAnimation<Color>(SpaceColors.neonCyan),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ENCRYPTED STORAGE",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SpaceColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "12.4 GB",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: SpaceColors.electricPurple),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "342 active nodes",
                        style: TextStyle(fontSize: 11, color: SpaceColors.textSecondary.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Navigation Shortcuts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("VAULT CATEGORIES", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DumpAreaScreen()),
                  );
                },
                child: const Text("Open Dump Area", style: TextStyle(color: SpaceColors.neonCyan)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Folders Simulation grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildCategoryShortcut("Education", Icons.school, SpaceColors.education),
              _buildCategoryShortcut("Career", Icons.work, SpaceColors.career),
              _buildCategoryShortcut("Health", Icons.healing, SpaceColors.health),
              _buildCategoryShortcut("Finance", Icons.account_balance_wallet, SpaceColors.finance),
              _buildCategoryShortcut("Important", Icons.description, SpaceColors.important),
              _buildCategoryShortcut("Saved Links", Icons.link, SpaceColors.savedLinks),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3DGalaxyView() {
    return Stack(
      children: [
        // Starfield Canvas
        const Positioned.fill(
          child: _GalaxyStarfieldPainter(),
        ),
        // HUD Overlay
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
            onPressed: () => setState(() => _showGalaxy = false),
          ),
        ),
        Positioned(
          top: 25,
          right: 20,
          child: Text(
            "3D MEMORY GALAXY",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: SpaceColors.neonCyan,
              letterSpacing: 1.5,
              shadows: [
                Shadow(color: SpaceColors.neonCyan.withOpacity(0.5), blurRadius: 10),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SpaceColors.spaceBlack.withOpacity(0.7),
              border: Border.all(color: SpaceColors.neonCyan.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Clusters represent categories. Pinch to Zoom. Tap stars to decrypt memory metadata.",
              style: TextStyle(fontSize: 11, color: SpaceColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureAssistantBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SpaceColors.midnightBlue.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpaceColors.electricPurple.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(color: SpaceColors.electricPurple.withOpacity(0.3), blurRadius: 12),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.screenshot_monitor, color: SpaceColors.electricPurple, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Memory Capture Assistant",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SpaceColors.electricPurple),
                ),
                Text(
                  "New screenshot detected. Save under Career?",
                  style: TextStyle(fontSize: 12, color: SpaceColors.textPrimary.withOpacity(0.9)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _showCaptureAssistant = false);
            },
            child: const Text("YES", style: TextStyle(color: SpaceColors.neonCyan, fontWeight: FontWeight.bold)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.grey),
            onPressed: () => setState(() => _showCaptureAssistant = false),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SpaceColors.midnightBlue.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpaceColors.glassWhite, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildCategoryShortcut(String title, IconData icon, Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: SpaceColors.midnightBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpaceColors.glassWhite, width: 0.8),
      ),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: accentColor, size: 24),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Painter for Neural Particle background
class _NeuralBackdropPainter extends StatefulWidget {
  const _NeuralBackdropPainter();

  @override
  State<_NeuralBackdropPainter> createState() => _NeuralBackdropPainterState();
}

class _NeuralBackdropPainterState extends State<_NeuralBackdropPainter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = List.generate(40, (index) => _Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var p in _particles) {
          p.update();
        }
        return CustomPaint(
          painter: _NeuralBackgroundPainter(_particles),
        );
      },
    );
  }
}

class _Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double vx = (math.Random().nextDouble() - 0.5) * 0.003;
  double vy = (math.Random().nextDouble() - 0.5) * 0.003;

  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

class _NeuralBackgroundPainter extends CustomPainter {
  final List<_Particle> particles;

  _NeuralBackgroundPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    // Fill background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = SpaceColors.spaceBlack,
    );

    // Draw lines
    final linePaint = Paint()
      ..color = SpaceColors.neonCyan.withOpacity(0.06)
      ..strokeWidth = 1.0;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final dx = (particles[i].x - particles[j].x) * size.width;
        final dy = (particles[i].y - particles[j].y) * size.height;
        final dist = math.sqrt(dx * dx + dy * dy);
        
        if (dist < 100) {
          canvas.drawLine(
            Offset(particles[i].x * size.width, particles[i].y * size.height),
            Offset(particles[j].x * size.width, particles[j].y * size.height),
            linePaint,
          );
        }
      }
    }

    // Draw dots
    final dotPaint = Paint()..color = SpaceColors.neonCyan.withOpacity(0.2);
    for (var p in particles) {
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom Painter for 3D Memory Galaxy representation
class _GalaxyStarfieldPainter extends CustomPainter {
  const _GalaxyStarfieldPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(12345);

    // Fill background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = SpaceColors.spaceBlack);

    // Draw Galaxy core
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          SpaceColors.electricPurple.withOpacity(0.6),
          SpaceColors.neonCyan.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 120));
    canvas.drawCircle(center, 120, corePaint);

    // Draw clusters as star nebulae
    final categories = [
      {'color': SpaceColors.education, 'angle': 0.0},
      {'color': SpaceColors.career, 'angle': math.pi / 2},
      {'color': SpaceColors.health, 'angle': math.pi},
      {'color': SpaceColors.finance, 'angle': 3 * math.pi / 2},
    ];

    for (var cat in categories) {
      final color = cat['color'] as Color;
      final angle = cat['angle'] as double;
      final clusterCenter = Offset(
        center.dx + 90 * math.cos(angle),
        center.dy + 90 * math.sin(angle),
      );

      // Draw cluster background glow
      final clusterGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            color.withOpacity(0.3),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: clusterCenter, radius: 40));
      canvas.drawCircle(clusterCenter, 40, clusterGlow);

      // Draw cluster stars (memories)
      final starPaint = Paint()..color = color;
      for (int i = 0; i < 15; i++) {
        final dist = random.nextDouble() * 30;
        final theta = random.nextDouble() * 2 * math.pi;
        final starPos = Offset(
          clusterCenter.dx + dist * math.cos(theta),
          clusterCenter.dy + dist * math.sin(theta),
        );
        canvas.drawCircle(starPos, 1.5 + random.nextDouble() * 2, starPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
