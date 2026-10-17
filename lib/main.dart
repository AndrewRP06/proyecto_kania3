import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_kania/ObjectsFirebase/firebase_options.dart';
import 'package:proyecto_kania/views/splash_view.dart';
import 'package:proyecto_kania/views/OnBoarding.dart';
import 'package:proyecto_kania/views/login_view.dart';
import 'package:proyecto_kania/views/register_view.dart';
import 'package:proyecto_kania/views/main_layout.dart';
import 'package:proyecto_kania/views/home_view.dart';
import 'package:proyecto_kania/views/races_view.dart';
import 'package:proyecto_kania/views/ranking_view.dart';
import 'package:proyecto_kania/views/perfil_view.dart';
import 'package:proyecto_kania/views/EditProfile_view.dart';

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
      onGenerateRoute: (settings) {
        // Rutas públicas que no requieren autenticación previa
        const rutasPublicas = ['/splash', '/onboarding', '/login', '/register'];

        if (rutasPublicas.contains(settings.name)) {
          Widget publicView = const SplashView();
          switch (settings.name) {
            case '/splash':
              publicView = const SplashView();
              break;
            case '/onboarding':
              publicView = const OnBoardingView();
              break;
            case '/login':
              publicView = const LoginView();
              break;
            case '/register':
              publicView = const RegisterView();
              break;
          }
          return MaterialPageRoute(builder: (_) => publicView, settings: settings);
        }

        // Comprobación de Autenticación (Auth Guard) para rutas protegidas
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          return MaterialPageRoute(
            builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes iniciar sesión antes de acceder a esta sección.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              });
              return const LoginView();
            },
            settings: settings,
          );
        }

        // Si el usuario está autenticado, permitir acceso a la ruta protegida solicitada
        Widget protectedView = const MainLayoutView();
        switch (settings.name) {
          case '/main':
            protectedView = const MainLayoutView();
            break;
          case '/home':
            protectedView = const HomeView();
            break;
          case '/races':
            protectedView = const RacesView();
            break;
          case '/ranking':
            protectedView = const RankingView();
            break;
          case '/perfil':
            protectedView = const PerfilView();
            break;
          case '/edit_profile':
            protectedView = const Editprofileview();
            break;
          default:
            protectedView = const MainLayoutView();
        }

        return MaterialPageRoute(builder: (_) => protectedView, settings: settings);
      },
    );
  }
}
