
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';

class SecondViolation extends StatelessWidget {
  _submit() {

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
    // userRef.child(currentUser!.uid).child("complain").set(driverCarInfoMap);
    userRef.child(firebaseAuth.currentUser!.uid).update({
      "counterLogin": "2",
    });



    //Fluttertoast.showToast(msg: "Successfully Saved, Wait for the admin to Approve you again");
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Violation Notice"),
      content: Text("This is your 2nd violation. Please report to your Toda President/admin for you to unblock and use the apps again."),
      actions: <Widget>[
        TextButton(
          child: Text("OK"),
          onPressed: () {

            _submit();
            firebaseAuth.signOut();
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Contact Us on Gmail"),
          onPressed: () {

            launchUrl(Uri.parse("mailto:trykeapp9@gmail.com"));
            _submit();
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
