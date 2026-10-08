import 'package:flutter/material.dart';
import 'package:proyecto_kania/views/main_layout.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  double _progreso = 0.0; // 1. Tu variable para controlar el % de la barra (de 0.0 a 1.0)

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 2. Aquí aumentamos el progreso progresivamente durante los 4 segundos
    for (int i = 1; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (!mounted) return;
      setState(() {
        _progreso = i / 100; // Va subiendo de 0.01 a 1.0 (100%)
      });
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainLayoutView()),
    );
  }

  Widget _buildCustomProgressBar(double progreso) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double anchoTotal = constraints.maxWidth;

        return Stack(
          children: [
            Container(
              height: 12,
              width: anchoTotal,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(76),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: 16,
              width: anchoTotal * progreso,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.cyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/imagen_de_carga.png',
                width: 200,
                height: 200,
                //Icono por si falla la carga de la imagen
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.car_crash,
                    size: 120,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kania',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: _buildCustomProgressBar(_progreso),
            ),
            const SizedBox(height: 12),
            Text(
              '${(_progreso * 100).toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
