
import 'dart:io';


import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/infoHandler/app_info.dart';
import 'package:users/screens/Disclaimer.dart';
import 'package:users/screens/complain.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/main_screen.dart';
import 'package:users/screens/rate_driver_screen.dart';
import 'package:users/screens/register_screen.dart';
import 'package:users/screens/search_places_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';
import 'package:users/themeProvider/theme_provider.dart';
import 'package:users/widgets/pay_fare_amount_dialog.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  Platform.isAndroid
      ? await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA0ak_aEyb_JJ1WAhZ0x4BhzYYjrUJi5Cg",
      appId: "1:513185890115:android:5cf2ca50b3fd348313b9f6",
      messagingSenderId: "513185890115",
      projectId: "tryke-app-with-admin-fd5e0",
    ),

  )

  :await Firebase.initializeApp(
    name: "user1",
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: 'Tryke App',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}


