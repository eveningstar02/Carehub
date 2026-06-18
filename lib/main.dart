import 'package:carehub_app/core/theme/app_theme.dart';
import 'package:carehub_app/data/supabase/supabase_service.dart';
import 'package:carehub_app/features/auth/auth_gate.dart';
import 'package:carehub_app/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  await SupabaseService.init();

  runApp(const ProviderScope(child: CareHubApp()));
}

class CareHubApp extends ConsumerWidget {
  const CareHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'CareHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const AuthGate(),
    );
  }
}
