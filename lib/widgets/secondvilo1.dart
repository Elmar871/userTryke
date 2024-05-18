
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class PermanentBanned extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Violation Notice"),
      content: Text("You are Permanently Banned"),
      actions: <Widget>[
        TextButton(
          child: Text("OK"),
          onPressed: () {

            //_submit();
            firebaseAuth.signOut();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Contact Us on Gmail"),
          onPressed: () {

            launchUrl(Uri.parse("mailto:trykeapp9@gmail.com"));
            //_submit();
            firebaseAuth.signOut();
            //Navigator.push(context, MaterialPageRoute(builder: (c)=> SplashScreen()));
          },
        ),
      ],
    );
  }
}

// Para ipakita ang dialog box:
// showDialog(context: context, builder: (context) => ViolationDialog());
