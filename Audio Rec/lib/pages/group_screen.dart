import 'package:audio_recording_in_flutter/pages/audio_home.dart';
import 'package:audio_recording_in_flutter/pages/message_screen.dart';
import 'package:flutter/material.dart';

class pageNotWorking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                child: Image(
                  width: 300,
                  image: AssetImage('images/panda.jpeg'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                child: Text("Page Not working",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                padding: EdgeInsets.symmetric(horizontal: 30),
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.black,
                  label: Text(
                    " Messages ",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed:  () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => audioHome()));
                  },
                  elevation: 0,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
            ],
          )
      ),
    );
  }
}
