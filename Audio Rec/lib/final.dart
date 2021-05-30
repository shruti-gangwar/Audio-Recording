import 'package:audio_recording_in_flutter/models/msg_model.dart';
import 'package:audio_recording_in_flutter/newfile.dart';
import 'package:audio_recording_in_flutter/pages/chat_screen.dart';
import 'package:audio_recording_in_flutter/pages/message_screen.dart';
import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

typedef _Fn = void Function();

class screen extends StatefulWidget {
  @override
  _screenState createState() => _screenState();
}

class _screenState extends State<screen> {

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
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  final String _mPath = 'flutter_sound_example.aac';
  var msgList = [];
  bool flag = true;

  @override
  void initState() {
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        print("shruti");
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      print("shrutiii3");
      var status = await Permission.microphone.request();
      print("shrutiii1");
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder.openAudioSession();
    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    _mRecorder
        .startRecorder(
      toFile: _mPath,
      codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);
    _mPlayer
        .startPlayer(
        fromURI: _mPath,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        whenFinished: () {
          setState(() {});
        })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer.stopPlayer().then((value) {
      setState(() {});
    });
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped ? record : stopRecorder;
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      return null;
    }
    return _mPlayer.isStopped ? play : stopPlayer;
  }


  Stream<int> stopWatchStream() {
    StreamController<int> streamController;
    Timer timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer.cancel();
        timer = null;
        counter = 0;
        streamController.close();
      }
    }

    void tick(_) {
      counter++;
      streamController.add(counter);
      if (!flag) {
        stopTimer();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
      onListen: startTimer,
      onCancel: stopTimer,
      onResume: startTimer,
      onPause: stopTimer,
    );

    return streamController.stream;
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
            backgroundColor: Color(0xff0e2546),
            leading: Row(
              children: [
                SizedBox(
                  width: 13,
                ),

                CircleAvatar(
                  foregroundColor: Theme.of(context).primaryColor,
                  backgroundColor: Colors.grey,
                ),
              ],
            ),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text("Shruti"),
                ],
              ),
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
              )
            ],
          ),
          body: Column(
            children: [
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
                        const Text(
                            "I've been having a problem with my computer."),
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
                      Bubble(
                        style: styleMe,
                        showNip: false,
                        margin: const BubbleEdges.only(top: 4),
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          padding: const EdgeInsets.all(3),
                          height: 50,
                          width: 250,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xfffbbec5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.white,
                                ),
                                onPressed: getPlaybackFn(),
                                //color: Colors.white,
                                //disabledColor: Colors.grey,
                                child: Icon(
                                  _mPlayer.isPlaying ? Icons
                                      .play_arrow_rounded : Icons.pause,
                                  color: Color(0xff0e2546),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(_mPlayer.isPlaying
                                  ? 'Playback in progress'
                                  : 'Player is stopped'),
                            ]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: getRecorderFn(),
            child: Icon(
              Icons.mic,
              color: Colors.white,
            ),
            backgroundColor: Color(0xfffbbec5),
          ),

        ),
      ),
    );
  }
}
