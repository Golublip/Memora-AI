import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/space_colors.dart';

class FloatingAddButton extends StatefulWidget {
  final Function(String action)? onActionSelected;

  const FloatingAddButton({super.key, this.onActionSelected});

  @override
  State<FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<FloatingAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.photo, 'label': 'Photo', 'action': 'photo', 'color': SpaceColors.personal},
    {'icon': Icons.videocam, 'label': 'Video', 'action': 'video', 'color': SpaceColors.personal},
    {'icon': Icons.picture_as_pdf, 'label': 'PDF', 'action': 'pdf', 'color': SpaceColors.education},
    {'icon': Icons.link, 'label': 'Link', 'action': 'link', 'color': SpaceColors.savedLinks},
    {'icon': Icons.note_add, 'label': 'Note', 'action': 'note', 'color': SpaceColors.aiGenerated},
    {'icon': Icons.mic, 'label': 'Voice', 'action': 'voice', 'color': SpaceColors.personal},
    {'icon': Icons.scanner, 'label': 'Scan', 'action': 'scan', 'color': SpaceColors.important},
    {'icon': Icons.card_membership, 'label': 'Certificate', 'action': 'certificate', 'color': SpaceColors.career},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Circular fan menu items
          ...List.generate(_menuItems.length, (index) {
            final item = _menuItems[index];
            final double angle = (index * (math.pi / 2) / (_menuItems.length - 1)) + math.pi;
            final double radius = 120.0;
            
            return AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                final double x = _expandAnimation.value * radius * math.cos(angle);
                final double y = _expandAnimation.value * radius * math.sin(angle);
                
                return Transform.translate(
                  offset: Offset(x, y),
                  child: Opacity(
                    opacity: _expandAnimation.value,
                    child: FloatingActionButton.small(
                      heroTag: 'fab_${item['action']}',
                      backgroundColor: SpaceColors.midnightBlue,
                      foregroundColor: item['color'],
                      elevation: 6,
                      onPressed: () {
                        _toggleMenu();
                        if (widget.onActionSelected != null) {
                          widget.onActionSelected!(item['action']);
                        }
                      },
                      child: Tooltip(
                        message: item['label'],
                        child: Icon(item['icon']),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          // Trigger Button
          FloatingActionButton(
            heroTag: 'fab_trigger',
            backgroundColor: SpaceColors.neonCyan,
            foregroundColor: SpaceColors.spaceBlack,
            shape: const CircleBorder(),
            elevation: 8,
            onPressed: _toggleMenu,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * (3 / 4) * math.pi,
                  child: const Icon(Icons.add, size: 28),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
