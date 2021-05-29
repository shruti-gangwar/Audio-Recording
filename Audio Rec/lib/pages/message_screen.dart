import 'package:audio_recording_in_flutter/pages/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:audio_recording_in_flutter/models/chat_model.dart';

class messageScreen extends StatefulWidget {
  @override
  _messageScreenState createState() => _messageScreenState();
}

class _messageScreenState extends State<messageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0e2546),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
            border: Border.all(
              color: Colors.white,
            ),
            borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: ListView.builder(itemCount: data.length,
          itemBuilder: (context,i)=> Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(data[i].url),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data[i].name, style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),),
                    Text(data[i].time, style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14.0,
                    ),),

                  ],
                ),
                subtitle: Container(
                  padding: EdgeInsets.only(top:5.0),
                  child: Text(data[i].message, style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(),
                    ),
                  );
                },
              ),
              Divider(
                height:10.0,
              ),
            ],
          ),),
      ),
    );

  }
}
