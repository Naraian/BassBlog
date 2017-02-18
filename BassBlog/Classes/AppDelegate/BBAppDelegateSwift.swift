//
//  BBAppDelegateSwift.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/3/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

import UIKit
import MediaPlayer

@UIApplicationMain
class BBAppDelegateSwift: UIResponder, UIApplicationDelegate
{
    var window : UIWindow?;
    
    override init()
    {
        
    }
    
    class var rootViewController : BBRootViewController
    {
        get
        {
            return self.instance.window!.rootViewController as! BBRootViewController;
        }
    }
    
    class var instance : BBAppDelegateSwift
    {
        get
        {
            return UIApplication.shared.delegate as! BBAppDelegateSwift;
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        BBUIUtils.customizeAppearance();
        
        BBModelManager.default().rootContext();
        
        self.window = UIWindow(frame: UIScreen.main.bounds);
        self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController();
        
        self.window!.makeKeyAndVisible();
        
        BBAnalytics.startSession();
        
        application.beginReceivingRemoteControlEvents();
        
        return true;
    }
    
    override func remoteControlReceived(with event: UIEvent?)
    {
        super.remoteControlReceived(with: event);
        
        if let subtype = event?.subtype
        {
            switch(subtype)
            {
                case .remoteControlPlay:
                    BBAudioManager.default().paused = false;
                
                case .remoteControlPause, .remoteControlStop:
                    BBAudioManager.default().paused = true;
                
                case .remoteControlTogglePlayPause:
                    BBAudioManager.default().togglePlayPause();
                
                case .remoteControlNextTrack:
                    BBAudioManager.default().playNext();
                
                case .remoteControlPreviousTrack:
                    BBAudioManager.default().playPrev();
                
                case .remoteControlEndSeekingBackward, .remoteControlEndSeekingForward: ()
    //                println(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo);
                
                default: ()
            }
        }
    }
}
