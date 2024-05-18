import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/screens/block/cancel3rd.dart';
import 'package:users/screens/block/cancelFirst.dart';
import 'package:users/screens/block/cancelsecondvilo.dart';
import 'package:users/screens/complain.dart';
import 'package:users/screens/forgot_password_screen.dart';
import 'package:users/screens/register_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';

import '../global/global.dart';
import '../widgets/secondvilo.dart';
import '../widgets/secondvilo1.dart';
import 'Disclaimer.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();

  bool _passwordVisible = false;

  // declare a GlobalKey
  final _formKey = GlobalKey<FormState>();
  void _submit1() async {
    // validate all the form fields
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if(snap.value != null){
            if ((snap.value as Map)["blockStatus"]=="no") {
              currentUser = auth.user;
              await Fluttertoast.showToast(msg: "Succesfully Login");
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => DisclaimerDialog()));
              }
            else
              firebaseAuth.signOut();
              firebaseAuth.signOut();
              await Fluttertoast.showToast(msg: "You are block");
            Navigator.push(context, MaterialPageRoute(builder: (c) => FirstOffense()));
          }
          else {
            await Fluttertoast.showToast(msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }
  void _submit2() async {
    // validate all the form fields
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if(snap.value != null){
            if ((snap.value as Map)["blockStatus"]=="yes" && (snap.value as Map)["counterLogin"]=="1" ) {
              currentUser = auth.user;
              //await Fluttertoast.showToast(msg: "Succesfully Login");
              Navigator.push(context,
                  MaterialPageRoute(builder: (c) => PermanentBanned()));
            }
            else {
              _submit1();
            }
          }
          else {
            await Fluttertoast.showToast(msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }
  void check() async {
    // validate all the form fields
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
           if(snap.value != null){
             if ((snap.value as Map)["blockStatus"] == "no") {
               showDialog(context: context, builder: (context) => PermanentBanned());
             }

             //   if ((snap.value as Map)["counterLogin"]==1){
              // //showDialog(context: context, builder: (context) => ViolationDialog());
              // // currentUser = auth.user;
              // // await Fluttertoast.showToast(msg: "Succesfully Login");
              //     Navigator.push(context, MaterialPageRoute(builder: (c) => DisclaimerDialog()));
            //}
            else
              _submit();
          }
          if(snap.value != null){
            if ((snap.value as Map)["counterLogin"] == "2" && (snap.value as Map)["blockStatus"] == "yes") {
              showDialog(context: context, builder: (context) => PermanentBanned());
            }

            //   if ((snap.value as Map)["counterLogin"]==1){
            // //showDialog(context: context, builder: (context) => ViolationDialog());
            // // currentUser = auth.user;
            // // await Fluttertoast.showToast(msg: "Succesfully Login");
            //     Navigator.push(context, MaterialPageRoute(builder: (c) => DisclaimerDialog()));
            //}
            else
              _submit();
          }
          else {
            await Fluttertoast.showToast(msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occured: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }

  void _submit5() async {
    // validate all the form fields
    if(_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
          email: emailTextEditingController.text.trim(),
          password: passwordTextEditingController.text.trim()
      ).then((auth) async {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if(snap.value != null){
            if ((snap.value as Map)["blockStatus"]=="no"){
              currentUser = auth.user;
              await Fluttertoast.showToast(msg: "Successfully Login");
              Navigator.push(context, MaterialPageRoute(builder: (c) => DisclaimerDialog()));
            }
            else {
              if ((snap.value as Map)["cancel"] == "1" || (snap.value as Map)["cancel"] == "2" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => CancelSecondViolation());}
              else if ((snap.value as Map)["cancel"] == "3" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => PermanentBanned3rd());}
              else if ((snap.value as Map)["cancel1"] == "0" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => CancelFirstOffense());}

              else if ((snap.value as Map)["counterLogin"] == "1" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => FirstOffense());
              } else if ((snap.value as Map)["counterLogin"] == "2" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => SecondViolation());}

              else if ((snap.value as Map)["counterLogin"] == "3" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => PermanentBanned());
              }


              else {
                await Fluttertoast.showToast(msg: "You are blocked");
                Navigator.push(context, MaterialPageRoute(builder: (c) => FirstOffense()));
              }
            }
          }
          else {
            await Fluttertoast.showToast(msg: "No record exists with this email");
            firebaseAuth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occurred: \n $errorMessage");
      });
    }
    else{
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }


  void _submit() async {
    // validate all the form fields
    if (_formKey.currentState!.validate()) {
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      ).then((auth) async {
        DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
        userRef.child(currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          switch (snap.value != null) {
            case true:
              if(snap.value != null){
                currentUser = auth.user;
                await Fluttertoast.showToast(msg: "Successfully Logged In");
                Navigator.push(context, MaterialPageRoute(builder: (c) => DisclaimerDialog()));
              }
              else if ((snap.value as Map)["counterLogin"] == "1" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => PermanentBanned());
              } else if ((snap.value as Map)["counterLogin"] == "2" && (snap.value as Map)["blockStatus"] == "yes") {
                showDialog(context: context, builder: (context) => PermanentBanned());
              } else if ((snap.value as Map)["blockStatus"] == "yes") {
                //Navigator.push(context, MaterialPageRoute(builder: (c) => ComplainDialog()));
              } else {
                //Navigator.push(context, MaterialPageRoute(builder: (c) => ComplainDialog()));
                await Fluttertoast.showToast(msg: "You are blocked");
              }
              break;
            case false:
              await Fluttertoast.showToast(msg: "No record exists with this email");
              firebaseAuth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
              break;
          }
        });
      }).catchError((errorMessage) {
        Fluttertoast.showToast(msg: "Error occurred: \n $errorMessage");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all fields are valid");
    }
  }
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return WillPopScope(
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          backgroundColor: darkTheme ? Colors.black : Color(0xFFA0BFE0), // Set background color here
          body: ListView(
            padding: EdgeInsets.all(0),
            children: [
              Column(
                children: [
                  Image.asset(darkTheme ? 'images/logo1.png' : 'images/logo1.png'),
                  SizedBox(height: 15,),
                  Text(
                    'LOGIN',
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
                                  prefixIcon: Icon(Icons.person, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
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
                                },
                                onChanged: (text) => setState(() {
                                  emailTextEditingController.text = text;
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
                                   // firebaseAuth.signOut();
                                   //   check();
                                   //   _submit();
                                    _submit5();
                                  },
                                  child: Text(
                                    'Login',
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
                                    "Doesn't have an account?",
                                    style: TextStyle(
                                      color: Color(0xFF1679AB),
                                      fontSize: 15,
                                    ),
                                  ),

                                  SizedBox(width: 5,),

                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (c) => RegisterScreen()));
                                    },
                                    child: Text(
                                      "Register",
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
      ), onWillPop: ()=> _onBackButtonPressed(context),);
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


