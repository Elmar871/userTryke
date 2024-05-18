import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/register_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';

import '../../global/global.dart';



class CancelFirstOffense extends StatefulWidget {
  @override
  _CancelFirstOffenseState createState() => _CancelFirstOffenseState();
}

class _CancelFirstOffenseState extends State<CancelFirstOffense> {
  final TextEditingController controller = TextEditingController();


  final _formKey = GlobalKey<FormState>();



  _submit() {

    //counter++;
    Map driverCarInfoMap = {
      "complain": controller.text.trim()
    };

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
    // userRef.child(currentUser!.uid).child("complain").set(driverCarInfoMap);
    userRef.child(firebaseAuth.currentUser!.uid).update({
      "cancel": "1",
      "ratingstoUserCancel" : "3.1",
      "blockStatus" : "no",
      "cancel1":"1"


      //"complain": controller.text.trim()
    });
    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));



    //Fluttertoast.showToast(msg: "Successfully Saved, Wait for the admin to Approve you again");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Warning'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Paumanhin, ang hindi pag sipot sa driver ay nangangahulugang fake booking,  '
                'Maaari itong makaapekto sa iyong paggamit ng aming serbisyo. '
                'Mangyaring tandaan na ang paulit-ulit na hindi pag sipot sa biyahe ay maaaring magresulta sa pag-block ng iyong account. '
                'Salamat sa iyong pang-unawa.'),

          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {

            _submit();

          },
          child: Text('Agree'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            firebaseAuth.signOut();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
