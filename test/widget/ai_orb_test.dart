import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/memory/presentation/widgets/ai_orb.dart';

void main() {
  group('AIOrb Widget Tests', () {
    testWidgets('Renders in Idle state with default chart icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIOrb(state: OrbState.idle),
          ),
        ),
      );

      // Verify basic elements
      expect(find.byType(AIOrb), findsOneWidget);
      expect(find.byIcon(Icons.bubble_chart), findsOneWidget);
    });

    testWidgets('Renders in Listening state with microphone icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIOrb(state: OrbState.listening),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.bubble_chart), findsNothing);
    });

    testWidgets('Renders in Processing state with sync icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AIOrb(state: OrbState.processing),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('Registers tap callbacks successfully', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AIOrb(
              state: OrbState.idle,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AIOrb));
      await tester.pump();

      expect(wasTapped, isTrue);
    });
  });
}
