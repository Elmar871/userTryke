
import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:users/screens/login_screen.dart';
import 'register_screen.dart';

import 'package:users/screens/main_screen.dart';
import 'package:users/screens/register_screen.dart';

class Otp extends StatelessWidget {

  const Otp({
    Key? key,
    required this.otpController
  }) : super(key: key);
  final TextEditingController otpController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: const InputDecoration(
          hintText: ('0'),
        ),
        onSaved: (value) {},
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {

  const OtpScreen({Key? key,required this.myauth,}) : super(key: key);
  final EmailOTP myauth ;
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();


  String otpController = "1234";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: ()=> _onBackButtonPressed(context),
      child:  Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {



              //Navigator.push(context, MaterialPageRoute(builder: (c) => emailOt()));

            },
            icon: const Icon(Icons.arrow_back_ios_new),
          ),
          // actions: [
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.info),
          //   ),
          // ],
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Icon(Icons.dialpad_rounded, size: 30),
            const SizedBox(
              height: 40,
            ),
            const Text(
              "Enter OTP",
              style: TextStyle(fontSize: 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Otp(
                  otpController: otp1Controller,
                ),
                Otp(
                  otpController: otp2Controller,
                ),
                Otp(
                  otpController: otp3Controller,
                ),
                Otp(
                  otpController: otp4Controller,
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            GestureDetector(
              onTap: (){

                //Navigator.push(context, MaterialPageRoute(builder: (c) => emailOt()));
              },
              child: Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 50,),

            ElevatedButton(
              onPressed: () async {
                if (await widget.myauth.verifyOTP(otp: otp1Controller.text +
                    otp2Controller.text +
                    otp3Controller.text +
                    otp4Controller.text) == true) {

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("OTP is verified"),



                  ));
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Invalid OTP"),
                  ));
                }
              },
              child: const Text(
                "Confirm",
                style: TextStyle(fontSize: 20),
              ),
            )
          ],
        ),
      ),
    );
  }
}
Future<bool> _onBackButtonPressed(BuildContext context) async {
  bool? exitApp= await showDialog(
      context: context,
      builder: (BuildContext context){
        return AlertDialog(
          title: const Text("Really??"),
          content: const Text("Do you want to close the apps??"),
          actions:<Widget> [
            TextButton(
              onPressed: (){
                Navigator.of(context).pop(false);
              }, child: const Text("No"),
            ),
            TextButton(
              onPressed: (){
                //Navigator.pop(context);
                SystemNavigator.pop();
                // Navigator.of(context).pop(true);
              }, child: const Text("Yes"),
            )
          ],
        );
      }
  );
  return exitApp ?? false;
}
