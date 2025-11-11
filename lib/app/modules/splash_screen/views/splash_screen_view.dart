import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_screen_controller.dart';

class SplashScreenView extends GetView<SplashScreenController> {
  const SplashScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onReady();
    });

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withOpacity(0.15),
              scheme.surfaceContainerHighest.withOpacity(0.35),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - value) * 20),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.onPrimary.withOpacity(0.04),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 30,
                              spreadRadius: 0,
                              offset: const Offset(0, 14),
                              color: Colors.black.withOpacity(0.08),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'FritzLine',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Journey Magic Companion.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    '© 2025 FritzLine. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.2,
                      color: scheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
