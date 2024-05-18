

import 'package:firebase_database/firebase_database.dart';

class TripsHistoryModel{
  String? time;
  String? originAddress;
  String? destinationAddress;
  String? status;
  String? fareAmount;
  String? car_details;
  String? driverName;
  String? ratings;
  String? driverPhone;
  //String? comments;
  String? commentofDriver;
  String? ratingtoUser;
  String? ratingtoDriver;

  TripsHistoryModel({
    this.time,
    this.originAddress,
    this.destinationAddress,
    this.status,
    this.fareAmount,
    this.car_details,
    this.driverName,
    this.ratings,
    this.driverPhone,
    //this.comments,
    this.commentofDriver,
    this.ratingtoUser,
    this.ratingtoDriver
  });

  TripsHistoryModel.fromSnapshot(DataSnapshot dataSnapshot){
    time = (dataSnapshot.value as Map)["time"];
    originAddress = (dataSnapshot.value as Map)["originAddress"];
    destinationAddress = (dataSnapshot.value as Map)["destinationAddress"];
    status = (dataSnapshot.value as Map)["status"];
    fareAmount = (dataSnapshot.value as Map)["fareAmount"];
    car_details = (dataSnapshot.value as Map)["car_details"];
    driverName = (dataSnapshot.value as Map)["driverName"];
    ratings = (dataSnapshot.value as Map)["ratings"];
    driverPhone = (dataSnapshot.value as Map) ["driverPhone"];
    //comments = (dataSnapshot.value as Map) ["comments"];
    commentofDriver = (dataSnapshot.value as Map) ["commentsofdriver"];
    ratingtoUser = (dataSnapshot.value as Map) ["ratingstoUser"];
    ratingtoDriver = (dataSnapshot.value as Map) ["ratingstoDriver"];
  }
}