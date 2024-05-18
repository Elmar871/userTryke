import 'dart:async';

import 'package:flutter/material.dart';
import 'package:users/Assistants/assistant_methods.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();


    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000), // Set the duration of the animation
    );

    // Create animation
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    // Start the animation
    _animationController.forward();

    startTimer();
  }

  @override
  void dispose() {
    // Dispose animation controller
    _animationController.dispose();
    super.dispose();
  }

  startTimer() async {
    if(firebaseAuth.currentUser != null){

      await AssistantMethods.readCurrentOnlineUserInfo();
      await AssistantMethods.readOnlineDriverCarInfo();
      await AssistantMethods.readOnTripInformation();
      Timer(Duration(seconds: 7), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MainScreen())); // Use pushReplacement to prevent going back to SplashScreen
      });
    }
    else{
      Timer(Duration(seconds: 7), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen())); // Use pushReplacement to prevent going back to SplashScreen
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA0BFE0),
      body: Center(
        child: FadeTransition(
          opacity: _animation, // Apply the fade animation
          child: Image.asset(
            "images/logo1.png",
            height: 300,
            width: 300,
          ),
        ),
      ),
    );
  }
}
