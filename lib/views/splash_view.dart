import 'package:flutter/material.dart';
import 'package:proyecto_kania/views/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  double _progreso = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    for (int i = 20; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      if (!mounted) return;
      setState(() {
        _progreso = i / 100;
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginView()),
    );
  }

  Widget _buildCustomProgressBar(double progreso) {
    const primaryOrange = Color(0xFFE54622);
    return LayoutBuilder(
      builder: (context, constraints) {
        double anchoTotal = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(
                height: 10,
                width: anchoTotal,
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 50),
                height: 10,
                width: anchoTotal * progreso,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [primaryOrange, Color(0xFFFF7A59)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFE54622);
    const darkBackground = Color(0xFF111111);

    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryOrange, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withAlpha(50),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: const Color(0xFF1B1B1B),
                  child: Image.asset(
                    'assets/images/imagen_de_carga.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 160,
                        color: const Color(0xFF1B1B1B),
                        child: const Icon(
                          Icons.sports_motorsports,
                          size: 80,
                          color: primaryOrange,
                        ),
                      );
      },
    ),
  ),
),
            ),
            const SizedBox(height: 32),
            const Text(
              'KANIA SWS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Plataforma de Karting',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF888888),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: _buildCustomProgressBar(_progreso),
            ),
            const SizedBox(height: 16),
            Text(
              '${(_progreso * 100).toInt()}%',
              style: const TextStyle(
                color: primaryOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
