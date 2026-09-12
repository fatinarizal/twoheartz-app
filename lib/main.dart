import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'views/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  runApp(const TwoHeartzApp());
}

class TwoHeartzApp extends StatelessWidget {
  const TwoHeartzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2HEARTZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE91E63),
          primary: const Color(0xFFE91E63),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}