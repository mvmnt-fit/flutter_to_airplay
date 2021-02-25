import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// This widget returns a UIView from swift with an AVPlayer inside,
/// it can be added as it is, or inside a Container to limit
/// and control its width and height.

class FlutterAVPlayerView extends StatelessWidget {
  const FlutterAVPlayerView({
    Key key,
    this.urlString,
    this.filePath,
    this.controller,
  })  : assert(urlString != null || filePath != null),
        super(key: key);

  /// URL string for the video file, if the file is to be played from the network.
  final urlString;

  /// Asset name/path for the video file that needs to be played.
  final filePath;

  /// Controller for the widget
  final FlutterAVPlayerViewController controller;

  /// This function packs the available parameters to be sent to native code.
  /// It will check for the URL first, if it is available, then it will be used,
  /// otherwise filePath will be used.
  /// It is preferred that only one of urlString or filePath is used at a time,
  /// if both are provided, application will prioritise urlString.
  Map getCreateParams() {
    Map params = {
      'class': 'FlutterAVPlayerView',
    };
    if (urlString != null && urlString.length > 0) {
      params['url'] = urlString;
    } else {
      params['file'] = filePath;
    }
    return params;
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType:
          'flutter_avplayer_view', // This is the identifier that helps distinguish different views in the native code.
      creationParams:
          getCreateParams(), // parameters to load the video in native code.
      creationParamsCodec:
          StandardMessageCodec(), 
      onPlatformViewCreated: 
          _onPlatformViewCreated,// messenger to decode message between flutter and native.
    );
  }

  void _onPlatformViewCreated(int id) {
    if (controller == null) {
      return;
    }
    controller.setChannelId(id);
  }
}

class FlutterAVPlayerViewController {

  final VoidCallback onPlaybackComplete;

  MethodChannel _channel;

  FlutterAVPlayerViewController({this.onPlaybackComplete});
  
  void setChannelId(id) {
    _channel = new MethodChannel('FlutterAVPlayerView/$id');
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'sendFromNative':
        if(call.arguments is String) {
          String text = call.arguments as String;
          if(text == "playerDidFinishPlaying") {
            if(onPlaybackComplete != null) onPlaybackComplete();
          }
        }
        return Future.value("");
    }
  }

  Future<void> receiveFromFlutter(String text) async {
    try {
      final String result = await _channel.invokeMethod('receiveFromFlutter', {"text": text});
      print("Result from native: $result");
    } on PlatformException catch (e) {
      print("Error from native: $e.message");
    }
  }
}