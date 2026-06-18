import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'features/memory/presentation/screens/home_screen.dart';

// Providers for global state settings
final dyslexiaModeProvider = StateProvider<bool>((ref) => false);
final apiPasswordProvider = StateProvider<String>((ref) => "default_vault_pwd");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (with dummy placeholders for local validation)
  try {
    await Supabase.initialize(
      url: 'https://placeholder-project.supabase.co',
      anonKey: 'placeholder-anon-key',
    );
  } catch (_) {
    // Suppress initialization errors during headless building
  }

  runApp(
    const ProviderScope(
      child: MemoraApp(),
    ),
  );
}

class MemoraApp extends ConsumerWidget {
  const MemoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDyslexic = ref.watch(dyslexiaModeProvider);

    return MaterialApp(
      title: 'Memora AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getThemeData(isDyslexicMode: isDyslexic),
      home: const HomeScreen(),
    );
  }
}
