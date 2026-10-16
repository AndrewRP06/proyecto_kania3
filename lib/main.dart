import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_kania/ObjectsFirebase/firebase_options.dart';
import 'package:proyecto_kania/views/splash_view.dart';
import 'package:proyecto_kania/views/OnBoarding.dart';
import 'package:proyecto_kania/views/login_view.dart';
import 'package:proyecto_kania/views/register_view.dart';
import 'package:proyecto_kania/views/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kania App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashView(),
        '/onboarding': (context) => const OnBoardingView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/main': (context) => const MainLayoutView(),
      },
    );
  }
}
