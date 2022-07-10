//
//  HDAudioPlayManager.swift
//  HDPublicUIProject
//
//  Created by 航电 on 2020/8/28.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import AVFoundation

public class HDAudioPlayManager: NSObject {
    static public let sharedInstance = HDAudioPlayManager();
    
    public var urlString:NSString {
        set {
            playerUrl = newValue;
            
            onSetUp();
        }
        get {
            return (playerUrl == nil ? "" : playerUrl!);
        }
    }
    
    private var playerLayer:AVPlayerLayer?
    private var player:AVPlayer?
    private var currentItem:AVPlayerItem?
    private var playerUrl:NSString?
    
    override init() {
        super.init();
        
        self.player = AVPlayer();
        self.playerLayer = AVPlayerLayer(player: self.player);
    }
    
    //TODO: >>> Private Actions
    private func onSetUp() {
        if playerUrl?.length == 0 {
            return;
        }
        
        var url:NSURL?
        if (playerUrl?.hasPrefix("http"))! || (playerUrl?.hasPrefix("https"))! {
            url = NSURL(string: playerUrl! as String)
        } else {
            url = NSURL(fileURLWithPath: playerUrl! as String)
        }
        
        let item = AVPlayerItem(url: url! as URL);
        self.currentItem = item;
        self.player?.replaceCurrentItem(with: self.currentItem);
        
        NotificationCenter.default.addObserver(self, selector: #selector(onAudioDidEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: self.currentItem);
    }
    
    @objc private func onAudioDidEnd(_ noty:Notification) {
        self.player?.seek(to: .zero, completionHandler: { (isFinish) in
            
        });
        
        NotificationCenter.default.post(name: NSNotification.Name("HDAudioPlayManager_AudioDidEnd_Notification"), object: nil);
    }
    
    //TODO: >>>>Public Actions
    public func onPlay() {
        self.player?.play();
    }
    
    public func onPause() {
        self.player?.pause();
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
}
