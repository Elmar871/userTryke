import 'dart:async';


import 'package:email_otp/email_otp.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:users/global/global.dart';

import 'package:users/screens/forgot_password_screen.dart';
import 'package:users/screens/login_screen.dart';
import 'package:users/screens/main_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';

import 'Disclaimer.dart';
import 'otp.dart';







class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmTextEditingController = TextEditingController();
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  bool _passwordVisible = false;
  late Timer _timer;
  int _start = 60;
  int clickCount = 0;




  //declare a GlobalKey
  final _formKey = GlobalKey<FormState>();
  EmailOTP myauth = EmailOTP();





  verifynow() async {
    myauth.setConfig(
      appEmail: "elmars972@gmail.com",
      appName: "Email OTP",
      userEmail: emailTextEditingController.text,
      otpLength: 4,
      otpType: OTPType.digitsOnly,
    );

    if (await myauth.sendOTP() == true) {
      _showOtpDialog(context, myauth);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Oops, OTP send failed"),
        ),
      );
    }
  }
  resend() async {
    myauth.setConfig(
      appEmail: "elmars972@gmail.com",
      appName: "Email OTP",
      userEmail: emailTextEditingController.text,
      otpLength: 4,
      otpType: OTPType.digitsOnly,
    );

    if (await myauth.sendOTP() == true) {
      _showOtpDialog(context, myauth);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP send failed"),
        ),
      );
    }
  }


  void _showOtpDialog(BuildContext context, EmailOTP myauth) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: ()=> _onBackButtonPressed(context),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Enter OTP",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (await myauth.verifyOTP(otp: otp1Controller.text +
                          otp2Controller.text +
                          otp3Controller.text +
                          otp4Controller.text) == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(""),
                          ),
                        );
                        _submit();
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) =>  LoginScreen()),
                        // );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Invalid OTP"),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),



                  TextButton(
                    onPressed: () {
                      if (clickCount < 5) {
                        setState(() {
                          clickCount++;
                        });
                        Navigator.pop(context);
                        Fluttertoast.showToast(msg: 'Hanggang 5 lang ang resend code nakaka $clickCount ka na.');
                        verifynow();
                      }
                      else{
                        Fluttertoast.showToast(msg: 'Button disabled. Limit reached.');

                      }
                    },
                    // ang onPressed para hindi clickable ang button
                    child: Text('Resend OTP'),
                    style: TextButton.styleFrom(
                      primary: (clickCount < 5) ? Colors.blue : Colors.grey,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Back'),
                  ),


                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void _submit() async {
    // validate all the form fields
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        currentUser = auth.user;

        if(currentUser != null){
          Map userMap = {
            "id": currentUser!.uid,
            "name": nameTextEditingController.text.trim(),
            "email": emailTextEditingController.text.trim(),
            "address": addressTextEditingController.text.trim(),
            "phone": phoneTextEditingController.text.trim(),
            "rid": "free",
            "ratingstoUser": "5.0",
            "rVehicleType": "none",
            "blockStatus": "no",
            "notesAdmin": "",
            "counterLogin" : "0",
            "ratingstoUserCancel":"5"
          };

          DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Successfully Login");
        Navigator.push(context, MaterialPageRoute(builder: (c) => DisclaimerDialog()));
        //verifynow();
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(context),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: darkTheme ? Colors.black : Color(0xFFA0BFE0),
          body: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset(darkTheme ? 'images/logo1.png' : 'images/logo1.png'),

                  SizedBox(height: 20,),

                  Text(
                    'REGISTER',
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Name",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.solid,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2),),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return 'Name can\'t be empty';
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid name";
                                  }
                                  if(text.length > 49){
                                    return "Name can\'t be more than 50";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  nameTextEditingController.text = text;
                                }),
                              ),

                              SizedBox(height: 20,),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.solid,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.email, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return 'Email can\'t be empty';
                                  }
                                  if(EmailValidator.validate(text) == true){
                                    return null;
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid email";
                                  }
                                  if(text.length > 99){
                                    return "Email can\'t be more than 100";
                                  }
                                  if(emailTextEditingController.text.contains("@gmail.com")){
                                    return "Please enter a valid email";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEditingController.text = text;
                                }),
                              ),

                              SizedBox(height: 20,),

                              IntlPhoneField(
                                showCountryFlag: false,
                                dropdownIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Phone",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.solid,
                                      )
                                  ),
                                ),
                                initialCountryCode: 'PH',
                                onChanged: (text) => setState(() {
                                  phoneTextEditingController.text = text.completeNumber;
                                }),
                              ),

                              TextFormField(
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(100)
                                ],
                                decoration: InputDecoration(
                                  hintText: "Address",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  ),
                                  filled: true,
                                  fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.solid,
                                      )
                                  ),
                                  prefixIcon: Icon(Icons.location_city, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return 'Address can\'t be empty';
                                  }
                                  if(text.length < 2) {
                                    return "Please enter a valid address";
                                  }
                                  if(text.length > 99){
                                    return "Address can\'t be more than 100";
                                  }
                                },
                                onChanged: (text) => setState(() {
                                  addressTextEditingController.text = text;
                                }),
                              ),

                              SizedBox(height: 20,),

                              TextFormField(
                                obscureText: !_passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.solid,
                                        )
                                    ),
                                    prefixIcon: Icon(Icons.lock, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2),
                                      ),
                                      onPressed: () {
                                        // update the state i.e toggle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    )
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return 'Password can\'t be empty';
                                  }
                                  if(text.length < 6) {
                                    return "Please enter a valid password";
                                  }
                                  if(text.length > 49){
                                    return "Password can\'t be more than 50";
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  passwordTextEditingController.text = text;
                                }),
                              ),

                              SizedBox(height: 20,),

                              TextFormField(
                                obscureText: !_passwordVisible,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50)
                                ],
                                decoration: InputDecoration(
                                    hintText: "Confirm Password",
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide(
                                          width: 0,
                                          style: BorderStyle.solid,
                                        )
                                    ),
                                    prefixIcon: Icon(Icons.lock, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                        color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2),
                                      ),
                                      onPressed: () {
                                        // update the state i.e toggle the state of passwordVisible variable
                                        setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        });
                                      },
                                    )
                                ),
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                validator: (text) {
                                  if(text == null || text.isEmpty){
                                    return 'Confirm Password can\'t be empty';
                                  }
                                  if(text != passwordTextEditingController.text){
                                    return "Password do not match";
                                  }
                                  if(text.length < 6) {
                                    return "Please enter a valid password";
                                  }
                                  if(text.length > 49){
                                    return "Password can\'t be more than 50";
                                  }
                                  return null;
                                },
                                onChanged: (text) => setState(() {
                                  confirmTextEditingController.text = text;
                                }),
                              ),

                              SizedBox(height: 20,),

                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2),
                                    onPrimary: darkTheme ? Colors.black : Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    minimumSize: Size(double.infinity, 50),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()){
                                      verifynow();
                                    }
                                  },
                                  child: Text(
                                    'Register',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )
                              ),

                              SizedBox(height: 20,),

                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => ForgotPasswordScreen()));
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: darkTheme ? Colors.amber.shade400 : Color(0xFF1C1678),
                                  ),
                                ),
                              ),

                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Have an account?",
                                    style: TextStyle(
                                      color: Color(0xFF1679AB),
                                      fontSize: 15,
                                    ),
                                  ),

                                  SizedBox(width: 5,),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
                                    },
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: darkTheme ? Colors.amber.shade400 : Color(0xFF1C1678),
                                      ),
                                    ),
                                  ),
                                ],
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
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