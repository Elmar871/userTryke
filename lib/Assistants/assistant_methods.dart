
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:users/Assistants/request_assistant.dart';
import 'package:users/global/global.dart';
import 'package:users/models/active_nearby_drivers_type.dart';
import 'package:users/models/trips_history_model.dart';
import 'package:users/models/user_model.dart';

import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/direction_details_info.dart';
import '../models/directions.dart';
import 'package:http/http.dart' as http;

class AssistantMethods {

  static readCurrentOnlineUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
      .ref()
      .child("users")
      .child(currentUser!.uid);

    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });
  }



  static double cancelcalculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo)
  {

    double distancePerKmAmount = 0;
    double baseFareAmount = 0;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceTravelFareAmount;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
    // double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.1;
    // double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.duration_value! / 1000) * 0.1;
    //
    // //USD
    // double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
    // double localCurrencyTotalFare = totalFareAmount * 107;
    //
    // if(driverVehicleType == "Bike"){
    //   double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 0.8);
    //   print("resultFareAmount Bike: ${resultFareAmount}");
    //   return resultFareAmount;
    // }
    // else if(driverVehicleType == "CNG"){
    //   double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 1.5);
    //   print("resultFareAmount CNG: ${resultFareAmount}");
    //   return resultFareAmount;
    // }
    // else if(driverVehicleType == "Car"){
    //   double resultFareAmount = ((localCurrencyTotalFare.truncate()) * 2.0);
    //   print("resultFareAmount Car: ${resultFareAmount}");
    //   return resultFareAmount;
    // }
    // else{
    //   print("Fare: ${localCurrencyTotalFare.truncate().toDouble()}");
    //   return localCurrencyTotalFare.truncate().toDouble();
    // }
    // //return double.parse(localCurrencyTotalFare.toStringAsFixed(1));
  }

  static readOnlineDriverCarInfo() async {
    // DatabaseReference carRef = FirebaseDatabase.instance
    //     .ref()
    //     .child("drivers")
    //     .child(driverID);
    //
    // carRef.once().then((snap){
    //   vehicleType?.add((snap.snapshot.value as dynamic)["car_details"]["type"]);
    //   print("List Car Type: ${vehicleType}");
    //   // print("Snap: ${(snap.snapshot.value as dynamic)["car_details"]["type"]}");
    // });

    try {
      DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

      DatabaseEvent firstEvent = await databaseReference.child("activeDrivers").once();
      DataSnapshot firstSnapshot = firstEvent.snapshot;
      Map<dynamic, dynamic>? firstDataMap = firstSnapshot.value as Map<dynamic, dynamic>?;

      print("First Data Map: ${firstDataMap!.keys}");

      DatabaseEvent secondEvent = await databaseReference.child("drivers").once();
      DataSnapshot secondSnapshot = secondEvent.snapshot;
      Map<dynamic, dynamic>? secondDataMap = secondSnapshot.value as Map<dynamic, dynamic>?;

      print("Second Data Map: ${secondDataMap!.values}");

      // Check if the snapshots' values are not null before proceeding
      if (firstDataMap != null && secondDataMap != null) {

        // Match keys between firstDataMap and secondDataMap
        Set<dynamic> matchedKeys = firstDataMap.keys.toSet().intersection(secondDataMap.keys.toSet());

        // Retrieve the desired field from the Firebase database using matched keys
        for (var key in matchedKeys) {
          print("KEY: ${key}");
          print("VALUES FROM SECOND DATABASE: ${secondDataMap[key]["car_details"]["type"]}");
          vehicleTypeInfoList!.add(VehicleTypeInfo(key, secondDataMap[key]["car_details"]["type"]));
        }
      }
    } catch (error) {
      print("Error while populating data list: $error");
    }
  }

  static readOnTripInformation() async {
    DatabaseReference rideRequestRef = FirebaseDatabase.instance
        .ref()
        .child("users")
        .child(userModelCurrentInfo!.id!);

    rideRequestRef.once().then((snap){
      var rid = (snap.snapshot.value as dynamic)["rid"];
      rVehicleType = (snap.snapshot.value as dynamic)["rVehicleType"];
      referenceRideRequest = FirebaseDatabase.instance.ref("All Ride Requests").child(rid);
      // print("Snap: ${(snap.snapshot.value as dynamic)["car_details"]["type"]}");
    });
  }

  static Future<String> searchAddressForGeographicCoOrdinates(Position position, context) async {

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

    if(requestResponse != "Error Occured. Failed. No Response."){
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static Future<DirectionDetailsInfo> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {

    String urlOriginToDestinationDirectionDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    // if(responseDirectionApi == "Error Occured. Failed. No Response."){
    //   return "";
    // }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }

  static double calculate1FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 5;
    double baseFareAmount = 20;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceTravelFareAmount;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }

  static double yescalculate1FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 5;
    double baseFareAmount = 10;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double percent = (baseFareAmount + totalDistanceTravelFareAmount) * 0.20;
    double overAllTotalFareAmount = (baseFareAmount + totalDistanceTravelFareAmount) - percent ;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }


  static double calculate2FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 10;
    double baseFareAmount = 40;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double overAllTotalFareAmount = baseFareAmount + totalDistanceTravelFareAmount;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }

  static double yescalculate2FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 10;
    double baseFareAmount = 40;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double percent = (baseFareAmount + totalDistanceTravelFareAmount) * 0.20;
    double overAllTotalFareAmount = (baseFareAmount + totalDistanceTravelFareAmount) - percent;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }


  static double calculate3FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 15;
    double baseFareAmount = 60;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double overAllTotalFareAmount = baseFareAmount;

    if (directionDetailsInfo.distance_value! > 1000) {
      overAllTotalFareAmount += totalDistanceTravelFareAmount;
    }

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }

  static double calculateFare4AmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 20;
    double baseFareAmount = 80;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;

    double overAllTotalFareAmount = baseFareAmount;

    if (directionDetailsInfo.distance_value! > 1000) {
      overAllTotalFareAmount += totalDistanceTravelFareAmount;
    }

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }





  static double yescalculate3FareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){

    double distancePerKmAmount = 15;
    double baseFareAmount = 60;

    double totalDistanceTravelFareAmount = (directionDetailsInfo.distance_value! / 1000) * distancePerKmAmount;
    double percent = (baseFareAmount + totalDistanceTravelFareAmount) * 0.20;
    double overAllTotalFareAmount = (baseFareAmount + totalDistanceTravelFareAmount) - percent;

    return double.parse(overAllTotalFareAmount.toStringAsFixed(0));
  }




  static sendNotificationToDriverNow(String deviceRegistrationToken, String userRideRequestId, context) async {
    String destinationAddress = userDropOffAddress;

    Map<String, String> headerNotification = {
      'Content-Type': 'application/json',
      'Authorization': cloudMessagingServerToken,
    };

    Map bodyNotification = {
      "body":"Destination Address: \n$destinationAddress.",
      "title":"New Trip Request"
    };

    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "rideRequestId": userRideRequestId
    };

    Map officialNotificationFormat = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };

    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormat),
    );
  }

  //retrieve the trips Keys for online user
  //trip key = ride request key
  static void readTripsKeysForOnlineUser(context){
    FirebaseDatabase.instance.ref().child("All Ride Requests").orderByChild("userName").equalTo(userModelCurrentInfo!.name).once().then((snap) {
      if(snap.snapshot.value != null){
        Map keysTripsId = snap.snapshot.value as Map;

        //count total number of trips and share it with Provider
        int overAllTripsCounter = keysTripsId.length;
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsCounter(overAllTripsCounter);

        //share trips keys with Provider
        List<String> tripsKeysList = [];
        keysTripsId.forEach((key, value) {
          tripsKeysList.add(key);
        });
        Provider.of<AppInfo>(context, listen: false).updateOverAllTripsKeys(tripsKeysList);

        //get trips keys data - read trips complete information
        readTripsHistoryInformation(context);
      }
    });
  }

  static void readTripsHistoryInformation(context){
    var tripsAllKeys = Provider.of<AppInfo>(context, listen: false).historyTripsKeysList;

    for(String eachKey in tripsAllKeys){
      FirebaseDatabase.instance.ref()
          .child("All Ride Requests")
          .child(eachKey)
          .once()
          .then((snap)
      {
        var eachTripHistory = TripsHistoryModel.fromSnapshot(snap.snapshot);

        if((snap.snapshot.value as Map)["status"] == "ended" ||(snap.snapshot.value as Map)["status"] == "cancelled" ){
          //update or add each history to OverAllTrips History data list
          Provider.of<AppInfo>(context, listen: false).updateOverAllTripsHistoryInformation(eachTripHistory);
        }
      });
    }
  }

}












