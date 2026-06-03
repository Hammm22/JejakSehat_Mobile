import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252C37),

      body: Stack(
        children: [
          Positioned(
            top: -135,
            right: -135,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFF8C61E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            top:-40,
            left:-40,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: Color(0xFFF8C61E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -45,
            right: -50,
            child: Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: Color(0xFFF8C61E),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -135,
            left: -135,
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                color: Color(0xFFF8C61E),
                shape: BoxShape.circle,
              ),
            ),
          ),


          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin:0.9, end: 1.35), 
              duration: const Duration(seconds: 3),
              curve: Curves.linear, builder: (context,scale,child) {
                return Transform.scale(
                  scale: scale,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/Logo.png',
                width: 260,
              )
            ),
          )
        ],
      ),
    );
  }
}
