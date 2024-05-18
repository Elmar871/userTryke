import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:users/models/trips_history_model.dart';

// Updated HistoryDesignUIWidget
class HistoryDesignUIWidget extends StatefulWidget {
  final TripsHistoryModel? tripsHistoryModel;

  const HistoryDesignUIWidget({Key? key, this.tripsHistoryModel}) : super(key: key);

  @override
  State<HistoryDesignUIWidget> createState() => _HistoryDesignUIWidgetState();
}

class _HistoryDesignUIWidgetState extends State<HistoryDesignUIWidget> {
  String formatDateAndTime(String dateTimeFromDB) {
    DateTime dateTime = DateTime.parse(dateTimeFromDB);
    String formattedDateTime =
        "${DateFormat.MMMd().format(dateTime)}, ${DateFormat.y().format(dateTime)} - ${DateFormat.jm().format(dateTime)}";
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDateAndTime(widget.tripsHistoryModel!.time!),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: darkTheme ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "Driver: ${widget.tripsHistoryModel!.driverName!}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "Contact: ${widget.tripsHistoryModel!.driverPhone!}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "From: ${(widget.tripsHistoryModel!.originAddress!).substring(0, 25)} ...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              // SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "To: ${(widget.tripsHistoryModel!.destinationAddress!).substring(0, 7)} ...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "Fare: ${widget.tripsHistoryModel!.fareAmount!}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.lightBlue),
                  SizedBox(width: 10),
                  Text(
                    "Ratings: ${widget.tripsHistoryModel!.ratingtoUser!}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                "Comment: ${(widget.tripsHistoryModel!.commentofDriver!)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        )
      ],
    );
  }
}
