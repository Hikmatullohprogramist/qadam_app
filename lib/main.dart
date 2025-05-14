import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qadam_app/app/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:qadam_app/app/services/challenge_service.dart';
import 'package:qadam_app/app/services/step_counter_service.dart';
import 'package:qadam_app/app/services/coin_service.dart';
import 'package:qadam_app/app/services/auth_service.dart';
import 'package:qadam_app/app/screens/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => StepCounterService()),
        ChangeNotifierProvider(create: (_) => CoinService()),
        ChangeNotifierProvider(create: (_) => ChallengeService()),
      ],
      child: const QadamApp(),
    ),
  );
}

class QadamApp extends StatelessWidget {
  const QadamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return MaterialApp(
      title: 'Qadam++',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4CAF50),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.green,
          accentColor: const Color(0xFFFFC107),
          backgroundColor: const Color(0xFFF5F5F5),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121)),
          displayMedium: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121)),
          bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF424242)),
          bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF616161)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      ),
      home: authService.isLoggedIn ? const SplashScreen() : const LoginScreen(),
    );
  }
}
