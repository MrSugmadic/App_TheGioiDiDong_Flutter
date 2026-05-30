import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_gioi_di_dong/screens/main/main_screen.dart';
import 'package:the_gioi_di_dong/core/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Sau 3 giây sẽ tự động chuyển sang MainScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryThis, // Màu vàng TGDD
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo app của bạn
            Image.asset('assets/images/anhnen.png', width: 150),
            const SizedBox(height: 20),
            // Vòng tròn xoay chờ (Loading)
            const CircularProgressIndicator(color: Colors.black),
          ],
        ),
      ),
    );
  }
}
