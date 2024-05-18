import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:users/global/global.dart';
import 'package:users/splashScreen/splash_screen.dart';

class Cancel_PayFareAmountDialog extends StatefulWidget {

  double? fareAmount;

  Cancel_PayFareAmountDialog({this.fareAmount});

  @override
  State<Cancel_PayFareAmountDialog> createState() => _Cancel_PayFareAmountDialogState();
}

class _Cancel_PayFareAmountDialogState extends State<Cancel_PayFareAmountDialog> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(height: 20,),

            Text("Fare Amount".toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 20,),

            Divider(
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.white,
            ),

            SizedBox(height: 10,),

            Text(
              "P "+widget.fareAmount.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTheme ? Colors.amber.shade400 : Colors.white,
                fontSize: 50,
              ),
            ),

            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "THE RIDE HAS BEEN CANCELLED",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
              ),
            ),

            SizedBox(height: 10,),

            Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: darkTheme ? Colors.amber.shade400 : Colors.white,
                ),
                onPressed: () async {
                  Fluttertoast.showToast(msg: "Cash Paid now you can rate the driver. Please wait.");

                  await FirebaseDatabase.instance.ref("users").child(userModelCurrentInfo!.id!).child("rVehicleType").set("none");

                  await FirebaseDatabase.instance.ref("users").child(userModelCurrentInfo!.id!).child("rid").set("free");

                  Future.delayed(Duration(milliseconds: 1000), (){
                    Navigator.pop(context, "Cash Paid 1");
                    // SystemNavigator.pop();
                   // Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BACK TO HOMEPAGE",
                      style: TextStyle(
                        fontSize: 19,
                        color: darkTheme ? Colors.black : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                  ],
                ),
              ),
            ),

            SizedBox(height: 10,),

          ],
        ),
      ),
    );
  }
}


















