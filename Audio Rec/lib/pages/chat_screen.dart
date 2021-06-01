import 'package:audio_recording_in_flutter/widgets/bottom_input.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_recording_in_flutter/models/msg_model.dart';

int count=0;

class ChatScreen extends StatefulWidget {
  final Function onPress;

  const ChatScreen({Key key,@required this.onPress}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const styleSomebody = BubbleStyle(
    nip: BubbleNip.leftCenter,
    color: Color(0xfff0f1f5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, right: 50),
    alignment: Alignment.topLeft,
  );
  static const styleMe = BubbleStyle(
    nip: BubbleNip.rightCenter,
    color: Color(0xfffbbec5),
    elevation: 1,
    margin: BubbleEdges.only(top: 8, left: 50),
    alignment: Alignment.topRight,
  );
  var msgList = [];
  FlutterSoundPlayer _myPlayer = FlutterSoundPlayer();
  bool _myPlayerIsInited = false;

  @override
  void initState() {
    _myPlayer.openAudioSession().then((value) {
      setState(() {
        _myPlayerIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _myPlayer.closeAudioSession();
    _myPlayer = null;
    super.dispose();
  }

  Future<void> playRecording(String uri) async {
    _myPlayer.startPlayer(
      fromURI: uri,
      codec: Codec.aacADTS,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery
        .of(context)
        .size
        .width;
    var height = MediaQuery
        .of(context)
        .size
        .height;
    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,

              title: Row(
                children: [
                  CircleAvatar(
                    foregroundColor: Theme
                        .of(context)
                        .primaryColor,
                    backgroundColor: Colors.grey,
                    backgroundImage: AssetImage('images/girl.jpeg'),
                    radius: 16,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    children: [
                      Text("Shruti", style: TextStyle(fontSize: 15.0,),),
                      Text("Online", style: TextStyle(fontSize: 10.0,color: Colors.grey),),
                    ],
                  ),
                ],
              ),
              elevation: 0.7,
              actions: <Widget>[
                Icon(Icons.phone),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5.0),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.video_call),
                ),
                Icon(Icons.more_vert),
              ],
            ),
            body: Stack(
              children: [
                Align(
                    alignment: Alignment.bottomLeft,
                    child: BottomInput(
                      width: width,
                      height: height,
                      count: count,
                      onAudioSend: (String path) {
                        setState(() {
                          msgList.add(Msg(
                              path: path,
                              toMe: false,
                              timestamp: "${DateTime
                                  .now()
                                  .millisecondsSinceEpoch}"));
                        });
                      },
                      onAudioCancel: () {},
                    )),
              ],
            )),
      ),
    );
  }

}




