import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const Sa7byApp());
}

final supabase = Supabase.instance.client;

class Sa7byApp extends StatelessWidget {
  const Sa7byApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صاحبي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A3AFF), // بنفسجي/كحلي
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1020),
      ),
      locale: const Locale('ar'),
      home: const AuthGate(),
    );
  }
}

// بيحدد يوديك لشاشة الدخول أو الصفحة الرئيسية حسب حالتك
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;
        if (session != null) {
          return const HomeScreen();
        }
        return const AuthScreen();
      },
    );
  }
}