import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F6),
      body: Column(
        children: [
          // Top spacer
          Expanded(
            flex: 2,
            child: Container(),
          ),
          // Logo section
          Expanded(
            flex: 3,
            child: const Center(
              child: LogoSection(),
            ),
          ),
          // Bottom spacer
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Loading indicator
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF6B6B),
                    ),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Decorative dots - top left
        Positioned(
          top: 20,
          left: 40,
          child: _DecorativeDot(
            size: 12,
            color: const Color(0xFFFFB3BA).withOpacity(0.6),
          ),
        ),
        // Decorative dots - top right
        Positioned(
          top: 30,
          right: 50,
          child: _DecorativeDot(
            size: 8,
            color: const Color(0xFFFFDCC8).withOpacity(0.7),
          ),
        ),
        // Decorative dots - bottom left
        Positioned(
          bottom: 40,
          left: 35,
          child: _DecorativeDot(
            size: 10,
            color: const Color(0xFFFFB3BA).withOpacity(0.5),
          ),
        ),
        // Decorative dots - bottom right
        Positioned(
          bottom: 25,
          right: 45,
          child: _DecorativeDot(
            size: 14,
            color: const Color(0xFFFFDCC8).withOpacity(0.6),
          ),
        ),
        // Main logo circle
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 70,
            ),
          ),
        ),
      ],
    );
  }
}

class _DecorativeDot extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeDot({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
