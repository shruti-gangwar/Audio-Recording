import 'package:audio_recording_in_flutter/widgets/bottom_input.dart';
import 'package:audio_recording_in_flutter/widgets/msg_box.dart';
import 'package:bubble/bubble.dart';
import 'package:bubble/issue_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:audio_recording_in_flutter/models/msg_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
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
  FlutterSoundPlayer _audioPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;

  @override
  void initState() {
    _audioPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.closeAudioSession();
    _audioPlayer = null;
    super.dispose();
  }

  Future<void> playRecording(String uri) async {
    _audioPlayer.startPlayer(
      fromURI: uri,
      codec: Codec.aacADTS,
    );
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return KeyboardSizeProvider(
      smallSize: 500.0,
      child: SafeArea(
        child: Scaffold(
            body: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top:17.0, left:7.0),
                      child: Row(

                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 9.0,
                          ),
                          CircleAvatar(
                            foregroundColor: Theme.of(context).primaryColor,
                            backgroundColor: Colors.grey,
                          ),
                          SizedBox(
                            width: 9.0,
                          ),
                          Text("Shruti", style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),),
                        ],
                      ),
                      height: 80,
                      color: Color(0xff0e2546),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 58.0),
                       /* decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/background.png"),
                            fit: BoxFit.cover,
                          ),
                        ),*/
                        child: ListView(
                          padding: const EdgeInsets.all(8),
                          children: [
                            Bubble(
                              alignment: Alignment.center,
                              color: const Color.fromARGB(255, 212, 234, 244),
                              margin: const BubbleEdges.only(top: 8),
                              child: const Text(
                                'TODAY',
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Bubble(
                              style: styleSomebody,
                              child: const Text(
                                  'Hi Jason. Sorry to bother you. I have a queston for you.'),
                            ),
                            Bubble(
                              style: styleMe,
                              child: const Text("Whats'up?"),
                            ),
                            Bubble(
                              style: styleSomebody,
                              child:
                              const Text("I've been having a problem with my computer."),
                            ),
                            Bubble(
                              style: styleSomebody,
                              margin: const BubbleEdges.only(top: 4),
                              showNip: false,
                              child: const Text('Can you help me?'),
                            ),
                            Bubble(
                              style: styleMe,
                              child: const Text('Ok'),
                            ),
                            Bubble(
                              style: styleMe,
                              showNip: false,
                              margin: const BubbleEdges.only(top: 4),
                              child: const Text("What's the problem?"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                    alignment: Alignment.bottomLeft,
                    child: BottomInput(
                      width: width,
                      height: height,
                      onAudioSend: (String path) {
                        setState(() {
                          msgList.add(Msg(
                              path: path,
                              toMe: false,
                              timestamp: "${DateTime.now().millisecondsSinceEpoch}"));
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