
import 'package:flutter/material.dart';

import '../global/global.dart';
import '../splashScreen/splash_screen.dart';
import 'login_screen.dart';

class TermsAndConditionsPage extends StatefulWidget {
  @override
  _TermsAndConditionsPageState createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'By downloading, installing, or using the Tryke Apps ("the App"), you agree to these Terms and Conditions, which constitute a legally binding agreement between you and the Tryke Apps development team. If you do not agree to these Terms and Conditions, do not download, install, or use the App.\n\n'
                      '1. Use of the App\n\n'
                      '1.1 The App is designed to facilitate booking rides with tricycle drivers in Sta. Cruz, Laguna.\n\n'
                  // '1.2 You must be at least 18 years old to use the App.\n\n'
                      '1.2 You agree to provide accurate and complete information when using the App, including your name, address, contact number, email, and location.\n\n'
                      '2. Privacy Policy\n\n'
                      '2.1 By using the App, you agree to the collection and use of your personal information in accordance with our Privacy Policy.\n\n'
                      '2.2 We may collect and store your personal information for the purpose of providing the services offered by the App.\n\n'
                      '3. Payment\n\n'
                      '3.1 The App currently only supports cash payments.\n\n'
                      '3.2 You agree to pay the fare displayed in the App for the services provided by the tricycle driver.\n\n'
                      '4. Limitation of Liability\n\n'
                      '4.1 The Tryke Apps development team is not liable for any damages, including but not limited to, direct, indirect, incidental, or consequential damages, arising out of the use or inability to use the App.\n\n'
                      '4.2 The Tryke Apps development team is not liable for any disputes or issues that may arise between you and the tricycle driver.\n\n'
                      '5. Changes to Terms and Conditions\n\n'
                      '5.1 The Tryke Apps development team reserves the right to modify or amend these Terms and Conditions at any time. Any changes will be effective immediately upon posting.\n\n'
                      '6. Contact Information\n\n'
                      '6.1 For questions or concerns about these Terms and Conditions, please contact us at [email address].\n\n'
                      '7. Governing Law\n\n'
                      '7.1 These Terms and Conditions are governed by and construed in accordance with the laws of the Philippines.',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (value) {
                    setState(() {
                      _agreed = value!;
                    });
                  },
                ),
                Text('I agree to the Terms and Conditions'),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    firebaseAuth.signOut();
                    Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                    // Add your logic here for when the user disagrees
                  },
                  child: Text('Disagree'),
                ),
                ElevatedButton(
                  onPressed: _agreed
                      ? () {
                    // Add your logic here for when the user agrees
                    Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                  }
                      : null,
                  child: Text('Agree'),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TermsAndConditionsPage(),
  ));
}

