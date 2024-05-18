import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';

import '../global/global.dart';
import 'Disclaimer.dart';

class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  _submit() {
    if (complaintController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: "Please Enter Your Report");
      return;
    }

    if (complaintController.text.trim().length < 5) {
      Fluttertoast.showToast(msg: "Report must be at least 5 characters");
      return;
    }

    Map reportMap = {
      "FullName": fullNameController.text.trim(),
      "Complaint": complaintController.text.trim(),
    };

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("complain").push();
    userRef.child("Report").set(reportMap);

    Fluttertoast.showToast(msg: "Successfully Saved, Wait for the admin to Approve you again");

    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
      // Update the UI to reflect changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complain'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Full Name (Optional):'),
            TextFormField(
              controller: fullNameController,
              decoration: InputDecoration(
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Text('Complaint:'),
            TextFormField(
              controller: complaintController,
              decoration: InputDecoration(
                hintText: 'Enter your complaint here',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
              maxLength: 100, // Maximum of 100 characters (approximately 10 words)
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your complaint';
                } else if (value.length < 5) {
                  return 'Complaint must be at least 10 characters';
                }
                return null;
              },
            ),


          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _submit();

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
