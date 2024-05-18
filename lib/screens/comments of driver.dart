
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';
import '../widgets/commetdesing.dart';
import '../widgets/history_design_ui.dart';

class Comments extends StatefulWidget {
  const Comments({Key? key}) : super(key: key);

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        title: Text(
          "Comments",
          style: TextStyle(
            color: darkTheme ? Colors.amber.shade400 : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: darkTheme ? Colors.amber.shade400 : Colors.black,),
          onPressed: ()
          {
            // SystemNavigator.pop();
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.separated(
          itemBuilder: (context, i)
          {
            return Card(
              color: darkTheme ? Colors.black : Colors.grey[100],
              shadowColor: Colors.transparent,
              child: CommentOfUser(
                tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
              ),
            );
          },
          separatorBuilder: (context, i) => SizedBox(height: 30,),
          itemCount: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList.length,),
      ),
    );
  }
}






















