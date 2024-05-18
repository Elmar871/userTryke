import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trips_history_model.dart';
import '../models/user_ride_request_information.dart';


class CommentOfUser extends StatefulWidget
{
  TripsHistoryModel? tripsHistoryModel;
  UserRideRequestInformation? userTrip;

  CommentOfUser({this.tripsHistoryModel});

  @override
  State<CommentOfUser> createState() => _CommentOfUserState();
}

class _CommentOfUserState extends State<CommentOfUser>
{


  @override
  Widget build(BuildContext context)
  {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    // Check kung may laman ang `comments` bago ipakita ang Column
    if (widget.tripsHistoryModel!.commentofDriver != null &&
        widget.tripsHistoryModel!.commentofDriver!.isNotEmpty) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Comments of Other Driver: \n" + widget.tripsHistoryModel!.commentofDriver!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return Container(); // Kung walang laman, gumamit ng Container para hindi mag-occupy ng space
    }



  }
}
