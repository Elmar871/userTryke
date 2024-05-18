
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users/screens/termsandcon.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'login_screen.dart';

class DisclaimerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(context),
      child: AlertDialog(
        title: Text(
          'Disclaimer',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'This app collects location data to enable Search Vehicle Location, Travel Route and Navigation, Realtime Vehicle Movement, even when the app is closed or not in use.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            child: Text('Cancel'),
            onPressed: () {
              firebaseAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.blue,
            ),
            child: Text('Proceed'),
            onPressed: () {
              // Add your logic here for when the user proceeds
              Navigator.push(context, MaterialPageRoute(builder: (c) => TermsAndConditionsPage()));
            },
          ),
        ],
      ),
    );
  }
}

Future<bool> _onBackButtonPressed(BuildContext context) async {
  bool? exitApp = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Really??"),
        content: const Text("Do you want to close the apps??"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              //Navigator.pop(context);
              SystemNavigator.pop();
              // Navigator.of(context).pop(true);
            },
            child: const Text("Yes"),
          )
        ],
      );
    },
  );
  return exitApp ?? false;
}
