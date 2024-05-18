import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/register_screen.dart';

import '../global/global.dart';
import 'Disclaimer.dart';
import 'complain.dart';

class ComplainDialog1 extends StatefulWidget {
  @override
  _ComplainDialog1State createState() => _ComplainDialog1State();
}

class _ComplainDialog1State extends State<ComplainDialog1> {
  final TextEditingController controller = TextEditingController();
  int counter = 2;

  final _formKey = GlobalKey<FormState>();

  void _submit1() async {
    // validate all the form fields

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
    userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
      final snap = value.snapshot;
      if (snap.value != null) {
        if ((snap.value as Map)["counterLogin"] == "1") {
          //await Fluttertoast.showToast(msg: "Succesfully Login");
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => RegisterScreen()));
        }
        else
          _submit();
      }
    });
  }


  _submit() {
    //counter++;
    Map driverCarInfoMap = {
      "complain": controller.text.trim()
    };

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
    DatabaseReference ratings = FirebaseDatabase.instance.ref().child("users").child("ratingstoUser");
    // userRef.child(currentUser!.uid).child("complain").set(driverCarInfoMap);
    userRef.child(currentUser!.uid).update({
      "counterLogin": counter++,
      "complain": controller.text.trim(),
      "ratingstoUser" : "2",
    });



    Fluttertoast.showToast(msg: "Successfully Saved, Wait for the admin to Approve you again");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complain'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Please provide details of your complaint:'),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Enter your complaint here',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _submit1();
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          },
          child: Text('Send Complain'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}
