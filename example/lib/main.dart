import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_to_airplay/flutter_to_airplay.dart';
import 'package:flutter_to_airplay/airplay_route_picker_view.dart';
import 'package:flutter_to_airplay/flutter_avplayer_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  FlutterAVPlayerViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlutterAVPlayerViewController(
      onPlaybackComplete: () => _onPlaybackComplete(),
    );
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterToAirplay.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _onPlaybackComplete() {
    print("_onPlaybackComplete");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text('Flutter 2 Airplay'),
              Text(
                _platformVersion,
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          actions: [
            Container(
              width: 44.0,
              height: 44.0,
              child: AirPlayRoutePickerView(
                tintColor: Colors.white,
                activeTintColor: Colors.white,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: FlutterAVPlayerView(
              // filePath: 'assets/videos/butterfly.mp4',
              controller: _controller,
              urlString:
                  'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
            ),
          ),
        ),
      ),
    );
  }
}
