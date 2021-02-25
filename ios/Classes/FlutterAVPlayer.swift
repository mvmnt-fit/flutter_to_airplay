//
//  FlutterAVPlayer.swift
//  flutter_to_airplay
//
//  Created by Junaid Rehmat on 22/08/2020.
//

import Foundation
import AVKit
import MediaPlayer
import Flutter

class FlutterAVPlayer: NSObject, FlutterPlatformView {
    private var _flutterAVPlayerViewController : AVPlayerViewController;
    private var _viewId: Int64
    private var _messenger: FlutterBinaryMessenger
    private var _channel: FlutterMethodChannel
    
    init(frame:CGRect,
          viewIdentifier: CLongLong,
          arguments: Dictionary<String, Any>,
          binaryMessenger: FlutterBinaryMessenger) {
        _viewId = viewIdentifier
        _messenger = binaryMessenger
        _channel = FlutterMethodChannel(name: "FlutterAVPlayerView/\(_viewId)", binaryMessenger: _messenger)
        _channel.setMethodCallHandler({ (call: FlutterMethodCall, result: FlutterResult) -> Void in
            switch call.method {
            case "receiveFromFlutter":
            guard let args = call.arguments as? [String: Any],
                let text = args["text"] as? String else {
                result(FlutterError(code: "-1", message: "Error", details: ""))
                return
            }
            print(text)
            //self.magicView.receiveFromFlutter(text)
            result("receiveFromFlutter success")
            default:
                result(FlutterMethodNotImplemented)
            }
        }) 
        _flutterAVPlayerViewController = AVPlayerViewController()
        _flutterAVPlayerViewController.viewDidLoad()
        if let urlString = arguments["url"] {
            let item = AVPlayerItem(url: URL(string: urlString as! String)!)
            _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)
        } else if let filePath = arguments["file"] {
            let appDelegate = UIApplication.shared.delegate as! FlutterAppDelegate
            let vc = appDelegate.window.rootViewController as! FlutterViewController
            let lookUpKey = vc.lookupKey(forAsset: filePath as! String)
            if let path = Bundle.main.path(forResource: lookUpKey, ofType: nil) {
                let item = AVPlayerItem(url: URL(fileURLWithPath: path))
                _flutterAVPlayerViewController.player = AVPlayer(playerItem: item)
            }
        }
        
        _flutterAVPlayerViewController.player!.play()
        
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: _flutterAVPlayerViewController.player?.currentItem)
    }

    public func sendFromNative(_ text: String) {
        _channel.invokeMethod("sendFromNative", arguments: text)
    }
    
    func view() -> UIView {
        return _flutterAVPlayerViewController.view;
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        sendFromNative("playerDidFinishPlaying")
    }
    
}

