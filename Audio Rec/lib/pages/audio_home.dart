import 'package:audio_recording_in_flutter/pages/group_screen.dart';
import 'package:audio_recording_in_flutter/pages/message_screen.dart';
import 'package:flutter/material.dart';

class audioHome extends StatefulWidget {
  @override
  _audioHomeState createState() => _audioHomeState();
}

class _audioHomeState extends State<audioHome>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff0e2546),
        title: Text("Chat"),
        elevation: 0.7,
        bottom: TabBar(
          indicatorSize: TabBarIndicatorSize.label,
          controller: _tabController,
          tabs: [
            Tab(text: "Messages"),
            Tab(text: "Groups"),
            Tab(text: "Calls"),

          ],
          indicatorColor: Colors.white,
        ),
        actions: <Widget>[
          Icon(Icons.search),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.0),
          ),
          Icon(Icons.more_vert)
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          messageScreen(),
          messageScreen(),
          messageScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => messageScreen()));
        },
        child: Icon(
          Icons.message,
          color: Colors.white,
        ),
        backgroundColor: Color(0xfffbbec5),
      ),
    );
  }
}
