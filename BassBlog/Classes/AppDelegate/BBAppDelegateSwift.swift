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
            return UIApplication.sharedApplication().delegate as! BBAppDelegateSwift;
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool
    {
        BBUIUtils.customizeAppearance();
        
        BBModelManager.defaultManager().rootContext();
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds);
        self.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController();
        
        self.window!.makeKeyAndVisible();
        
        BBAnalytics.startSession();
        
        application.beginReceivingRemoteControlEvents();
        
        return true;
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?)
    {
        super.remoteControlReceivedWithEvent(event);
        
        if let subtype = event?.subtype
        {
            switch(subtype)
            {
                case .RemoteControlPlay:
                    BBAudioManager.defaultManager().paused = false;
                
                case .RemoteControlPause, .RemoteControlStop:
                    BBAudioManager.defaultManager().paused = true;
                
                case .RemoteControlTogglePlayPause:
                    BBAudioManager.defaultManager().togglePlayPause();
                
                case .RemoteControlNextTrack:
                    BBAudioManager.defaultManager().playNext();
                
                case .RemoteControlPreviousTrack:
                    BBAudioManager.defaultManager().playPrev();
                
                case .RemoteControlEndSeekingBackward, .RemoteControlEndSeekingForward: ()
    //                println(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo);
                
                default: ()
            }
        }
    }
}
