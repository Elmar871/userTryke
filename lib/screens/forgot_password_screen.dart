import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/screens/login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  final emailTextEditingController = TextEditingController();

  // declare a GlobalKey
  final _formKey = GlobalKey<FormState>();

  void _submit() {
    firebaseAuth.sendPasswordResetEmail(
        email: emailTextEditingController.text.trim()
    ).then((value){
      Fluttertoast.showToast(msg: "We have sent you an email to recover password, please check email");
    }).onError((error, stackTrace){
      Fluttertoast.showToast(msg: "Error Occured: \n ${error.toString()}");
    });
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

                  SizedBox(height: 20,),

                  Text(
                    'Forgot Password ',
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
                                  prefixIcon: Icon(Icons.email_outlined, color: darkTheme ? Colors.amber.shade400 : Color(0xFF4A55A2)),
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
                                    _submit();
                                  },
                                  child: Text(
                                    'Send Reset Password link',
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                  )
                              ),

                              SizedBox(height: 20,),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
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
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: darkTheme ? Colors.amber.shade400 : Color(0xFF1C1678),
                                      ),
                                    ),
                                  )
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



