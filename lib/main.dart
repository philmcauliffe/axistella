import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:axistella/dashboard_screen.dart';
import 'package:axistella/discovery_screen.dart';
import 'package:axistella/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Try to load from Environment (Dart Defines) - Best for Prod
  String sbUrl = const String.fromEnvironment('SB_URL');
  String sbKey = const String.fromEnvironment('SB_KEY');

  // 2. Fallback to config.json - Best for Local Dev
  if (sbUrl.isEmpty || sbKey.isEmpty) {
    try {
      final configString = await rootBundle.loadString('assets/config.json');
      final config = jsonDecode(configString) as Map<String, dynamic>;
      sbUrl = config['SB_URL'] ?? '';
      sbKey = config['SB_KEY'] ?? '';
    } catch (e) {
      // Config file might not exist in Prod if using Dart Defines
    }
  }

  await Supabase.initialize(
    url: sbUrl,
    anonKey: sbKey,
  );

  runApp(const AxistellaApp());
}

class AxistellaApp extends StatelessWidget {
  const AxistellaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Axistella',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4), // Deep Purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        return session != null ? const MainScaffold() : const LoginScreen();
      },
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const DiscoveryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Values Journey'),
        ],
      ),
    );
  }
}
