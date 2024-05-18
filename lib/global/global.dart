
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users/models/direction_details_info.dart';

import '../models/active_nearby_drivers_type.dart';
import '../models/user_model.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
User? currentUser;

UserModel? userModelCurrentInfo;
String cloudMessagingServerToken ="key=AAAAd3xDP0M:APA91bElANN_UonXLOIsWEDd85BU78WdOrTZ3IarOsRjtz5V-4nV861ETDCeE-80Tm-YSi9je0GQOp1BCc5ez1TqDIqd2jiFFSc4nZb7mk3W-JP3OpWrVRo3u4gbClt5vl4R0X8d7ic9";


List driversList = [];
List<VehicleTypeInfo>? vehicleTypeInfoList = [];

DatabaseReference? referenceRideRequest;

String? rVehicleType;

DirectionDetailsInfo? tripDirectionDetailsInfo;
String userDropOffAddress = "";
String driverCarDetails = "";
String driverName = "";
//String comments = "";
String driverPhone = "";
String driverRatings = "";
String userName = "";
String counterLogin = "";
String userPhone = "";

double countRatingStars = 0.0;
String titleStarsRating = "";
