import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class CommentProfile extends StatefulWidget {
  const CommentProfile({Key? key}) : super(key: key);

  @override
  _CommentProfileState createState() => _CommentProfileState();
}

class _CommentProfileState extends State<CommentProfile> {
  final ref = FirebaseDatabase.instance.ref('drivers');
  List<String> favorites = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Comments"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FirebaseAnimatedList(
              query: ref,
              itemBuilder: (context, snapshot, animation, index) {
                final driverName = snapshot.child('name').value.toString().replaceAll('{', '').replaceAll('}', '');
                final commentText = snapshot.child('comments').value.toString().replaceAll('{', '').replaceAll('}', '');
                final commentKey = snapshot.key.toString();
                final isFavorite = favorites.contains(commentKey);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Example background color
                      borderRadius: BorderRadius.circular(8.0), // Example border radius
                    ),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Example padding
                            child: Text(
                              'Driver: $driverName',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '$commentText',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      trailing: IconButton(
                        icon: isFavorite ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
                        onPressed: () {
                          setState(() {
                            if (isFavorite) {
                              favorites.remove(commentKey);
                            } else {
                              favorites.add(commentKey);
                            }
                          });
                        },
                      ),
                      onTap: () {
                        // Implement onTap functionality here
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
