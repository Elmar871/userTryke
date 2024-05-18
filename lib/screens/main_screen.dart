import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:users/Assistants/assistant_methods.dart';
import 'package:users/Assistants/black_theme_google_map.dart';
import 'package:users/Assistants/geofire_assistant.dart';
import 'package:users/global/global.dart';
import 'package:users/infoHandler/app_info.dart';
import 'package:users/models/active_nearby_available_drivers.dart';
import 'package:users/models/drivers_info.dart';
import 'package:users/screens/comments%20of%20driver.dart';
import 'package:users/screens/drawer_screen.dart';
import 'package:users/screens/precise_pickup_location.dart';
import 'package:users/screens/rate_driver_screen.dart';
import 'package:users/screens/rate_driver_screen_cancel.dart';
import 'package:users/screens/search_places_screen.dart';
import 'package:users/splashScreen/splash_screen.dart';
import 'package:users/widgets/pay_fare_amount_dialog_cancel.dart';
import 'package:users/widgets/progress_dialog.dart';

import '../global/trip_var.dart';
import '../models/directions.dart';
import '../models/user_ride_request_information.dart';
import '../widgets/cancel_pay_fare_amount_dialog.dart';
import '../widgets/pay_fare_amount_dialog.dart';
import 'login_screen.dart';

Future<void> _makePhoneCall(String url) async {
  if(await canLaunch(url)) {
    await launch(url);
  }
  else {
    throw "Could not launch $url";
  }
}

class MainScreen extends StatefulWidget {
  CarModel? carModel;
  UserRideRequestInformation? userRideRequestDetails;

  MainScreen({
    this.userRideRequestDetails
});


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final controllerNotes =TextEditingController();


  LatLng? pickLocation;


  loc.Location location = loc.Location();
  String? _address;
  var counter = 0;
  bool isChecked = false;


  List<String> details = ["1", "2", "3", "4"];
  String? selectedNumber;
  List<String> dis = ["Yes", "No"];
  String? discount;
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;


  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(14.2691, 121.4113),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignedDriverInfoContainerHeight = 0;
  double suggestedRidesContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;



  Position? userCurrentPosition;
  var geoLocation = Geolocator();

  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoOrdinatesList = [];
  Set<Polyline> polylineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  //String userName = "";
  String phone = "";
  String userEmail = "";

  bool openNavigationDrawer = true;

  bool activeNearbyDriverKeysLoaded = false;

  BitmapDescriptor? carIcon;
  BitmapDescriptor? cngIcon;
  BitmapDescriptor? bikeIcon;

  // DatabaseReference? referenceRideRequest;

  String selectedVehicleType = "";

  String driverRideStatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubscription;

  List<ActiveNearByAvailableDrivers> onlineNearByAvailableDriversList = [];

  String userRideRequestStatus = "";
  bool requestPositionInfo = true;




  locateUserPosition() async {
    Position cPostion = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPostion;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoOrdinates(userCurrentPosition!, context);
    print("This is our address = " + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();

    AssistantMethods.readTripsKeysForOnlineUser(context);
    getUserInfoAndCheckBlockStatus();
    getUserInfoAndCheckBlockStatus1();
    cancelRatings();


  }

  // cancelTripNow() async {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) => ProgressDialog(message:  "Please wait....",)
  //   );
  //
  //
  //   var tripDirectionDetails = await AssistantMethods.obtainOriginToDestinationDirectionDetails(widget.userRideRequestDetails!.originLatLng!, widget.userRideRequestDetails!.destinationLatLng!);
  //
  //   Navigator.pop(context);
  //
  //   //fare amount
  //   double totalFareAmount = AssistantMethods.cancelcalculateFareAmountFromOriginToDestination(tripDirectionDetails);
  //
  //   FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("fareAmount").set(totalFareAmount.toString());
  //
  //   FirebaseDatabase.instance.ref().child("All Ride Requests").child(widget.userRideRequestDetails!.rideRequestId!).child("status").set("cancelled");
  //
  //
  //
  //   //display fare amount in dialog box
  //   showDialog(
  //       context: context,
  //       builder: (BuildContext context) => Cancel_PayFareAmountDialog(
  //       )
  //   );
  //
  // }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, userCurrentPosition!.longitude, 0.8)!
      .listen((map) async {
       print("Map: $map");

       if(map != null) {
         var callBack = map["callBack"];

         switch(callBack) {
            //whenever any driver become active/online
            case Geofire.onKeyEntered:
              //GeoFireAssistant.activeNearByAvailableDriversList.clear();
              ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
              activeNearByAvailableDrivers.locationLatitude = map["latitude"];
              activeNearByAvailableDrivers.locationLongitude = map["longitude"];
              activeNearByAvailableDrivers.driverId = map["key"];
              for(var vehicleType in vehicleTypeInfoList!){
                if(vehicleType.driverID == map["key"]){
                  activeNearByAvailableDrivers.vehicleType = vehicleType.vehicleType;
                }
              }
              GeoFireAssistant.activeNearByAvailableDriversList.add(activeNearByAvailableDrivers);
              if(activeNearbyDriverKeysLoaded == true) {
                displayActiveDriversOnUsersMap();
              }
              break;
           //whenever any driver become non-active/online
           case Geofire.onKeyExited:
             displayActiveDriversOnUsersMap();
             GeoFireAssistant.deleteOfflineDriverFromList(map["key"]);

             break;

           //whenever driver moves - update driver location
           case Geofire.onKeyMoved:
             displayActiveDriversOnUsersMap();
             ActiveNearByAvailableDrivers activeNearByAvailableDrivers = ActiveNearByAvailableDrivers();
             activeNearByAvailableDrivers.locationLatitude = map["latitude"];
             activeNearByAvailableDrivers.locationLongitude = map["longitude"];
             activeNearByAvailableDrivers.driverId = map["key"];
             for(var vehicleType in vehicleTypeInfoList!){
               if(vehicleType.driverID == map["key"]){
                 activeNearByAvailableDrivers.vehicleType = vehicleType.vehicleType;
               }
             }
             GeoFireAssistant.updateActiveNearByAvailableDriverLocation(activeNearByAvailableDrivers);

             break;

           //display those online active drivers on user's map
           case Geofire.onGeoQueryReady:
             displayActiveDriversOnUsersMap();
             activeNearbyDriverKeysLoaded = true;
             break;
         }
       }

       setState(() {

       });
    });
  }

  getUserInfoAndCheckBlockStatus() async
  {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap)
    {
      if(snap.snapshot.value != null)
      {
        if((snap.snapshot.value as Map)["blockStatus"] == "no")
        {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
            userPhone = (snap.snapshot.value as Map)["phone"];
          });
        }
        else
        {
          FirebaseAuth.instance.signOut();

          Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));

          Fluttertoast.showToast(msg: "You are Blocked");
        }
      }
      else
      {
        FirebaseAuth.instance.signOut();
        Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
      }
    });
  }
  void getUserInfoAndCheckBlockStatus1() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);

    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double ratingsToUser = double.parse((snap.snapshot.value as Map)["ratingstoUser"] ?? "0");
        if (ratingsToUser <= 3 ) {
          // Update blockStatus to 'yes' if ratingsToUser is below 1
          usersRef.update({"blockStatus": "yes"}).then((_) {
            setState(() {
              userName = (snap.snapshot.value as Map)["name"];
              userPhone = (snap.snapshot.value as Map)["phone"];
            });
          });
        } else if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoginScreen()));
          Fluttertoast.showToast(msg: "You are Blocked");
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  void cancelRatings() async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid);


    await usersRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        double ratingsToUser = double.parse((snap.snapshot.value as Map)["ratingstoUserCancel"] ?? "0");
        if (ratingsToUser <= 3 ) {
          // Update blockStatus to 'yes' if ratingsToUser is below 1
          usersRef.update({"blockStatus": "yes","cancel1":"0"}).then((_) {
            setState(() {
              userName = (snap.snapshot.value as Map)["name"];
              userPhone = (snap.snapshot.value as Map)["phone"];
            });
          });
        } else if ((snap.snapshot.value as Map)["blockStatus"] == "no") {
          setState(() {
            userName = (snap.snapshot.value as Map)["name"];
          });
        } else {
          FirebaseAuth.instance.signOut();
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => LoginScreen()));
          Fluttertoast.showToast(msg: "You are Blocked");
        }
      } else {
        FirebaseAuth.instance.signOut();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }




  displayActiveDriversOnUsersMap() {
    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> carsMarkerSet = Set<Marker>();
      Set<Marker> cngMarkerSet = Set<Marker>();
      Set<Marker> bikeMarkerSet = Set<Marker>();

      for(ActiveNearByAvailableDrivers eachDriver in GeoFireAssistant.activeNearByAvailableDriversList) {

        //print("Each Driver Id: ${eachDriver.driverId}");
        //AssistantMethods.readOnlineDriverCarInfo(eachDriver.driverId!);

        LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        print("EACH DRIVER VEHICLE TYPE: ${eachDriver.vehicleType}");

        if(eachDriver.vehicleType == "Tricycle") {


          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: carIcon!,
            rotation: 360,
          );

          carsMarkerSet.add(marker);
        }
        else if(eachDriver.vehicleType == "CNG") {

          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: cngIcon!,
            rotation: 360,
          );

          cngMarkerSet.add(marker);
        }
        else if(eachDriver.vehicleType == "Bike") {

          Marker marker = Marker(
            markerId: MarkerId(eachDriver.driverId!),
            position: eachDriverActivePosition,
            icon: bikeIcon!,
            rotation: 360,
          );

          bikeMarkerSet.add(marker);
        }
      }

      setState(() {
        markersSet.addAll(carsMarkerSet);
        markersSet.addAll(cngMarkerSet);
        markersSet.addAll(bikeMarkerSet);
      });

    });
  }

  createActiveNearByDriverIconMarker() {
    ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size:Size.square(1));
    for(var vehicleType in vehicleTypeInfoList!){
      if(carIcon == null && cngIcon == null && bikeIcon == null){
        if(vehicleType.vehicleType == "Tricycle") {
          BitmapDescriptor.fromAssetImage(imageConfiguration, "images/Car2.png").then((value){
            carIcon = value;
            print("IMAGE VALUE 1: $value");
          });
        }
        else if(vehicleType.vehicleType == "CNG") {
          BitmapDescriptor.fromAssetImage(imageConfiguration, "images/cng_top_view.png").then((value){
            cngIcon = value;
            print("IMAGE VALUE 2: $value");
          });
        }
        else if(vehicleType.vehicleType == "Bike") {
          BitmapDescriptor.fromAssetImage(imageConfiguration, "images/bike_top_view.png").then((value){
            bikeIcon = value;
            print("IMAGE VALUE 3: $value");
          });
        }
      }
    }

  }

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Please wait...",),
    );

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoOrdinatesList.clear();

    if(decodePolyLinePointsResultList.isNotEmpty) {
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLng){
        pLineCoOrdinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color:  darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoOrdinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );

      polylineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if(originLatLng.latitude > destinationLatLng.latitude && originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    }
    else if(originLatLng.longitude > destinationLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    }
    else if(originLatLng.latitude > destinationLatLng.latitude){
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markersSet.add(originMarker);
      markersSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.red,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });

  }

  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  void showSuggestedRidesContainer(){
    setState(() {
      suggestedRidesContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  // getAddressFromLatLng() async {
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: pickLocation!.latitude,
  //         longitude: pickLocation!.longitude,
  //         googleMapApiKey: mapKey
  //     );
  //     setState(() {
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationLatitude = pickLocation!.latitude;
  //       userPickUpAddress.locationLongitude = pickLocation!.longitude;
  //       userPickUpAddress.locationName = data.address;
  //
  //       Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
  //
  //       // _address = data.address;
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if(_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }


  saveRideRequestInformation(String selectedVehicleType){
    if(userModelCurrentInfo!.rid == "free") {
      //1. save the rideRequest Information
      referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push();

      //referenceRideRequest!.update({"driverId": "waiting"});

      var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
      var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;



      String fareAmount;
      if (tripDirectionDetailsInfo != null) {
        if (selectedNumber == '1' || selectedNumber == '2' || selectedNumber == '3') {
          fareAmount = AssistantMethods.calculate3FareAmountFromOriginToDestination(tripDirectionDetailsInfo!).toString();
        } else if (selectedNumber == '4') {
          fareAmount = AssistantMethods.calculateFare4AmountFromOriginToDestination(tripDirectionDetailsInfo!).toString();
        } else {
          fareAmount = AssistantMethods.calculate3FareAmountFromOriginToDestination(tripDirectionDetailsInfo!).toString(); // Default value if no option is selected
        }
      } else {
        fareAmount = "";
      }

      Map originLocationMap = {
        //"key: value"
        "latitude": originLocation!.locationLatitude.toString(),
        "longitude": originLocation.locationLongitude.toString(),
      };

      Map destinationLocationMap = {
        //"key: value"
        "latitude": destinationLocation!.locationLatitude.toString(),
        "longitude": destinationLocation.locationLongitude.toString(),
      };

      Map userInformationMap = {
        "rid": referenceRideRequest?.key,
        "origin": originLocationMap,
        "destination": destinationLocationMap,
        "time": DateTime.now().toString(),
        "userId": userModelCurrentInfo!.id,
        "userName": userModelCurrentInfo!.name,
        "ratingstoUser": userModelCurrentInfo!.rateOfUser != null && userModelCurrentInfo!.rateOfUser!.isNotEmpty
            ? userModelCurrentInfo!.rateOfUser!
            : "No ratings Yet",
        "userPhone": userModelCurrentInfo!.phone,
        "originAddress": originLocation.locationName,
        "destinationAddress": destinationLocation.locationName,
        "notes":controllerNotes.text,
        "fareAmount": fareAmount,
        "selected": selectedNumber?.toString() ?? '1',
        // "discount" : discount.toString(),
        // "fareAmount1" : fareAmount1,

        "driverId": "waiting",

      };

      referenceRideRequest!.set(userInformationMap);
    }

    tripRidesRequestInfoStreamSubscription = referenceRideRequest!.onValue.listen((eventSnap) async {
      if(eventSnap.snapshot.value == null) {
        return;
      }

      if((eventSnap.snapshot.value as Map)["car_details"] != null){
        setState(() {
          driverCarDetails = (eventSnap.snapshot.value as Map)["car_details"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverPhone"] != null){
        setState(() {
          driverPhone = (eventSnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverName"] != null){
        setState(() {
          driverName = (eventSnap.snapshot.value as Map)["driverName"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["ratings"] != null){
        setState(() {
          driverRatings = (eventSnap.snapshot.value as Map)["ratings"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["status"] != null){
        setState(() {
          userRideRequestStatus = (eventSnap.snapshot.value as Map)["status"].toString();
        });
      }

      if((eventSnap.snapshot.value as Map)["driverLocation"] != null){
        double driverCurrentPositionLat = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["latitude"].toString());
        double driverCurrentPositionLng = double.parse((eventSnap.snapshot.value as Map)["driverLocation"]["longitude"].toString());

        LatLng driverCurrentPositionLatLng = LatLng(driverCurrentPositionLat, driverCurrentPositionLng);

        //status = accepted
        if(userRideRequestStatus == "accepted"){
          updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng);

        }
        //status = arrived
        if(userRideRequestStatus == "arrived"){
          setState(() {
            driverRideStatus = "Driver has arrived";
          });
        }

        //status = ontrip
        if(userRideRequestStatus == "ontrip"){
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }

        if(userRideRequestStatus == "ended"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
              context: context,
              builder: (BuildContext context) => PayFareAmountDialog(
                fareAmount: fareAmount,
              )
            );

            if(response == "Cash Paid"){
              //user can rate the driver now
              if((eventSnap.snapshot.value as Map)["driverId"] != null){
                String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (c) => RateDriverScreen(
                  assignedDriverId: assignedDriverId,
                )));

                referenceRideRequest!.onDisconnect();
                tripRidesRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
        if(userRideRequestStatus == "cancelled"){
          if((eventSnap.snapshot.value as Map)["fareAmount"] != null){
            double fareAmount = double.parse((eventSnap.snapshot.value as Map)["fareAmount"].toString());

            var response = await showDialog(
                context: context,
                builder: (BuildContext context) => PayFareAmountDialogCancel(
                  fareAmount: fareAmount,
                )
            );

            if(response == "Cancel"){
              //user can rate the driver now
              if((eventSnap.snapshot.value as Map)["driverId"] != null){
                // String assignedDriverId = (eventSnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen(
                )));
                referenceRideRequest!.onDisconnect();
                tripRidesRequestInfoStreamSubscription!.cancel();
              }
            }
          }
        }
      }

    });

    onlineNearByAvailableDriversList = GeoFireAssistant.activeNearByAvailableDriversList;
    searchNearestOnlineDrivers(selectedVehicleType);
  }

  searchNearestOnlineDrivers(String selectedVehicleType) async {
    if(userModelCurrentInfo!.rid == "free"){
      if(onlineNearByAvailableDriversList.length == 0) {
        //cancel/delete the rideRequest Information
        referenceRideRequest!.remove();

        setState(() {
          polylineSet.clear();
          markersSet.clear();
          circlesSet.clear();
          pLineCoOrdinatesList.clear();
        });

        Fluttertoast.showToast(msg: "No online nearest Driver Available");
        Fluttertoast.showToast(msg: "Search Again. \n Restarting App");

        Future.delayed(Duration(milliseconds: 1000), () {
          referenceRideRequest!.remove();
          Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
        });

        return;
      }

      await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);

      print("Driver List: " + driversList.toString());

      for(int i = 0;i < driversList.length; i++) {
        if(driversList[i]["car_details"]["type"] == selectedVehicleType && driversList[i]["newRideStatus"] == "idle"){
          await AssistantMethods.sendNotificationToDriverNow(driversList[i]["token"], referenceRideRequest!.key!, context);
          counter++;
          print("Counter: $counter");
        }
      }

      if(counter > 0){
        Fluttertoast.showToast(msg: "Notification sent Successfully");
      }
      else {
        Fluttertoast.showToast(msg: "No online nearest Driver Available");
        Fluttertoast.showToast(msg: "Search Again. \n Restarting App");

        Future.delayed(Duration(milliseconds: 100), () {
          referenceRideRequest!.remove();
          Navigator.push(context, MaterialPageRoute(builder: (c) => SplashScreen()));
        });
      }

      showSearchingForDriversContainer();
    }

    await FirebaseDatabase.instance.ref().child("All Ride Requests").child(referenceRideRequest!.key!).child("driverId").onValue.listen((eventRideRequestSnapshot) {
      print("RIDE REQUEST REFERENCE 2: ${referenceRideRequest!.key}");
      print("EventSnapshot: ${eventRideRequestSnapshot.snapshot.value}");
      if(eventRideRequestSnapshot.snapshot.value != null){
        if(eventRideRequestSnapshot.snapshot.value != "waiting"){
          showUIForAssignedDriverInfo();
        }
      }
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriversList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");

    for(int i = 0;i < onlineNearestDriversList.length; i++){
      await ref.child(onlineNearestDriversList[i].driverId.toString()).once().then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;

        //onlineNearByAvailableDriversList!.removeAt(0);



        driversList.add(driverKeyInfo);
        print("driver key information = " + driversList.toString());
      });
    }
  }



  updateArrivalTimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if(requestPositionInfo == true){
      requestPositionInfo = false;
      LatLng userPickUpPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
          driverCurrentPositionLatLng, userPickUpPosition,
      );

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Driver is coming: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if(requestPositionInfo == true){
      requestPositionInfo = false;

      var dropOffLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

      LatLng userDestinationPosition = LatLng(
        dropOffLocation!.locationLatitude!,
        dropOffLocation.locationLongitude!,
      );

      var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(
        driverCurrentPositionLatLng,
        userDestinationPosition
      );

      if(directionDetailsInfo == null){
        return;
      }
      setState(() {
        driverRideStatus = "Going Towards Destination: " + directionDetailsInfo.duration_text.toString();
      });

      requestPositionInfo = true;
    }
  }

  showUIForAssignedDriverInfo() {
    setState(() {
      waitingResponsefromDriverContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignedDriverInfoContainerHeight = 200;
      suggestedRidesContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    checkIfLocationPermissionAllowed();
    if(userModelCurrentInfo!.rid != "free") {
      print("RIDE REFERENCE: ${referenceRideRequest!.key}");
      saveRideRequestInformation(rVehicleType!);
    }
  }


  @override
  Widget build(BuildContext context) {

    createActiveNearByDriverIconMarker();
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;


    return WillPopScope(child:  GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldState,
        drawer: DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 30, bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polylineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController controller){
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;

                if(darkTheme == true){
                  setState(() {
                    blackThemeGoogleMap(newGoogleMapController);
                  });
                }

                setState(() {
                  bottomPaddingOfMap = 200;
                });

                locateUserPosition();
              },
              // onCameraMove: (CameraPosition? position){
              //   if(pickLocation != position!.target){
              //     setState(() {
              //       pickLocation = position.target;
              //     });
              //   }
              // },
              // onCameraIdle: () {
              //   getAddressFromLatLng();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            //     child: Image.asset("images/pick.png",height: 45, width: 45,),
            //   ),
            // ),

            //custom hamburger button for drawer
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    _scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: darkTheme ? Colors.black : Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            ),

            //ui for searching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: darkTheme ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.grey.shade900 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("From",
                                            style: TextStyle(
                                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(Provider.of<AppInfo>(context).userPickUpLocation != null
                                              ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24) + "..."
                                              : "Not Getting Address",
                                            style: TextStyle(color: Colors.grey, fontSize: 14),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),

                                SizedBox(height: 5,),

                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                ),

                                SizedBox(height: 5,),

                                Padding(
                                  padding: EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      //go to search places screen
                                      var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchPlacesScreen()));

                                      if(responseFromSearchScreen == "obtainedDropoff"){
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }

                                      await drawPolyLineFromOriginToDestination(darkTheme);

                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("To",
                                              style: TextStyle(
                                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context).userDropOffLocation != null
                                                  ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                                  : "Search For Dropoff Location",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: 5,),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.push(context, MaterialPageRoute(builder: (c) => PrecisePickUpScreen()));
                              //   },
                              //   child: Text(
                              //     "Pick Up Address",
                              //     style: TextStyle(
                              //       color: darkTheme ? Colors.black : Colors.white,
                              //     ),
                              //   ),
                              //   style: ElevatedButton.styleFrom(
                              //       primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              //       textStyle: TextStyle(
                              //         fontWeight: FontWeight.bold,
                              //         fontSize: 16,
                              //       )
                              //   ),
                              // ),
                              //
                              // SizedBox(width: 10,),

                              ElevatedButton(
                                onPressed: () {
                                  if(Provider.of<AppInfo>(context,listen: false).userDropOffLocation != null){
                                    showSuggestedRidesContainer();
                                    getUserInfoAndCheckBlockStatus();
                                    cancelRatings();
                                    getUserInfoAndCheckBlockStatus1();
                                  }
                                  else{
                                    Fluttertoast.showToast(msg: "Please select destination location");
                                    getUserInfoAndCheckBlockStatus();
                                    cancelRatings();
                                    getUserInfoAndCheckBlockStatus1();
                                  }
                                },
                                child: Text(
                                  "Show Fare",
                                  style: TextStyle(
                                    color: darkTheme ? Colors.black : Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    )
                                ),
                              ),

                            ],
                          ),

                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            //ui for suggested rides
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRidesContainerHeight,
                decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    )
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 15,),

                          Text(
                            Provider.of<AppInfo>(context).userPickUpLocation != null
                                ? (Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 24) + "..."
                                : "Not Getting Address",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 5,),

                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              Icons.star,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 15,),

                          Text(
                            Provider.of<AppInfo>(context).userDropOffLocation != null
                                ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!
                                : "Where to?",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20,),

                      SizedBox(height: 1,),

                      // Text("SUGGESTED RIDES",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),

                      // SizedBox(height: 20,),



                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedVehicleType = "Tricycle";
                                counter = 0;
                                //displayActiveDriversOnUsersMap(selectedVehicleType);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedVehicleType == "Tricycle" ? (darkTheme ? Colors.amber.shade400 : Colors.blue) : (darkTheme ? Colors.black54 : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(25.0),
                                child: Column(

                                  children: [

                                    Image.asset("images/Car.png", scale: 15,),

                                    SizedBox(height: 3,),

                                    Text(
                                      "Tricycle",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedVehicleType == "Tricycle" ? (darkTheme ? Colors.black : Colors.white) : (darkTheme ? Colors.white : Colors.black),
                                      ),
                                    ),

                                    SizedBox(height: 2,),

                                    Text(
                                      (tripDirectionDetailsInfo != null)
                                          ? (selectedNumber == '1' || selectedNumber=='2'||selectedNumber== '3')
                                          ?  (tripDirectionDetailsInfo != null) ? "\₱ ${(AssistantMethods.calculate3FareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString()}":""
                                          : (selectedNumber == '4')
                                          ?  (tripDirectionDetailsInfo != null) ? "\₱ ${(AssistantMethods.calculateFare4AmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString()}":""
                                          : "\₱  ${(AssistantMethods.calculate3FareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString()}" // Default value if no option is selected
                                          : "",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),

                                  ],
                                ),

                              ),

                            ),



                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Number of Passengers',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                                ),
                              ),
                              SizedBox(
                                width: 200, // Set the desired width
                                child: DropdownButtonFormField(
                                  isDense: true, // Reduce the height of the button
                                  itemHeight: 48, // Set the height of the dropdown items
                                  decoration: InputDecoration(
                                    hintText: 'Select Number of Passengers',
                                    prefixIcon: Icon(
                                      Icons.groups,
                                      size: 18,
                                      color: darkTheme ? Colors.amber.shade400 : Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: darkTheme ? Colors.black45 : Colors.grey.shade200,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        width: 0,
                                        style: BorderStyle.none,
                                      ),
                                    ),
                                  ),
                                  value: selectedNumber != null ? selectedNumber : details.first,
                                  items: details.map((detail) {
                                    return DropdownMenuItem(
                                      child: Text(
                                        detail,
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      value: detail,
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      selectedNumber = newValue.toString();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),



                        ],
                      ),

                      SizedBox(height: 1,),



                      TextField(
                        keyboardType: TextInputType.text,
                        textAlign: TextAlign.center,
                        controller: controllerNotes,
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          hintText: "Notes to Driver",
                        ),
                      ),

                      SizedBox(height: 2,),





                      Expanded(
                        child:
                        GestureDetector(

                          onTap: () {

                            if(selectedVehicleType != "" ){


                              saveRideRequestInformation(selectedVehicleType);



                            }
                            else{
                              Fluttertoast.showToast(msg: "Please select a vehicle from \n suggested rides.");
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(
                              child: Text(
                                "Book Now",
                                style: TextStyle(
                                  color: darkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10,),
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              borderRadius: BorderRadius.circular(10)
                          ),
                          child: Center(
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: darkTheme ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),



                    ],
                  ),
                ),
              ),
            ),

            //Requesting a ride
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15) , topRight: Radius.circular(15)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      ),

                      SizedBox(height: 10,),

                      Center(
                        child: Text(
                          "Searching for a driver...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),

                      GestureDetector(
                        onTap: () {
                          referenceRideRequest!.remove();
                          setState(() {
                            searchingForDriverContainerHeight = 0;
                            suggestedRidesContainerHeight = 0;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: Icon(Icons.close, size: 25,),
                        ),
                      ),

                      SizedBox(height: 15,),

                      Container(
                        width: double.infinity,
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),


            //UI for displaying assigned driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignedDriverInfoContainerHeight,
                decoration: BoxDecoration(
                    color: darkTheme ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(driverRideStatus,style: TextStyle(fontWeight: FontWeight.bold),),
                      SizedBox(height: 1,),
                      Divider(thickness: 1, color: darkTheme ? Colors.grey : Colors.grey[300],),
                      SizedBox(height: 1,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {

                                  //MaterialPageRoute(builder: (context) => CommentProfile());
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Comments()),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: darkTheme ? Colors.amber.shade400 : Colors.lightBlue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Icon(Icons.person, color: darkTheme ? Colors.black : Colors.white,),
                                ),
                              ),

                              // Container(
                              //   padding: EdgeInsets.all(10),
                              //   decoration: BoxDecoration(
                              //     color: darkTheme ? Colors.amber.shade400 : Colors.lightBlue,
                              //     borderRadius: BorderRadius.circular(5),
                              //   ),
                              //   child: Icon(Icons.person, color: darkTheme ? Colors.black : Colors.white,),
                              //
                              // ),

                              SizedBox(width: 2,),

                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driverName,style: TextStyle(fontWeight: FontWeight.bold),),
                                  SizedBox(),

                                  // Text(fareAmount,style: TextStyle(fontWeight: FontWeight.bold),),

                                  Row(children: [
                                    Icon(Icons.star,color: Colors.orange,),

                                    SizedBox(width: 5,),

                                    Text(driverRatings,
                                      style: TextStyle(
                                          color: Colors.grey
                                      ),
                                    ),




                                    // Text(
                                    //   widget.userRideRequestDetails!.fareAmount!,
                                    //   style: TextStyle(
                                    //     fontSize: 16,
                                    //     color: darkTheme ? Colors.amberAccent : Colors.black,
                                    //   ),
                                    // ),
                                  ],),

                                  SizedBox(height: 5,),
                                  Text(
                                    (tripDirectionDetailsInfo != null) ? "Pamasahe: \₱ ${(AssistantMethods.calculate3FareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString()}" : "",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),

                                ],
                              )

                            ],
                          ),


                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Image.asset("images/Car.png", scale:10,),

                              //Text(widget.activeNearByAvailableDrivers!.vehicleType!);
                              Text(driverCarDetails, style: TextStyle(fontSize: 12),),
                            ],
                          )

                        ],
                      ),

                      SizedBox(height: 1,),


                      Divider(thickness: 1, color: darkTheme ? Colors.grey : Colors.grey[300],),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                            ElevatedButton.icon(
                              onPressed: () {
                                launchUrl(Uri.parse("tel://$driverPhone"));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              ),
                              icon: Icon(Icons.phone),
                              label: Text("Call Driver"),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Add code here for sending a message to the driver
                                launchUrl(Uri.parse("sms://$driverPhone"));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: darkTheme ? Colors.amber.shade400 : Colors.blue,
                              ),
                              icon: Icon(Icons.message),
                              label: Text("Message Driver"),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),

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













