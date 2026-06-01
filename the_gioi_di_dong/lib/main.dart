import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_gioi_di_dong/providers/user_profile_provider.dart';
import 'package:the_gioi_di_dong/screens/splash/splash_screen.dart';
import 'package:the_gioi_di_dong/providers/cart_provider.dart';
import 'package:the_gioi_di_dong/services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => UserProfileProvider()..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Thế Giới Di Động',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto', // Font chữ phổ biến, dễ nhìn
        useMaterial3: true,
      ),
      // Bắt đầu app bằng màn hình chờ
      home: const SplashScreen(),
    );
  }
}
