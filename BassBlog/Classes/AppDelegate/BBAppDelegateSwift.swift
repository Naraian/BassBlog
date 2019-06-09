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
class BBAppDelegateSwift: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    class var rootViewController: BBRootViewController {
        return self.instance.window!.rootViewController as! BBRootViewController
    }
    
    class var instance: BBAppDelegateSwift {
        return UIApplication.shared.delegate as! BBAppDelegateSwift
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        BBUIUtils.customizeAppearance()
        
        BBModelManager.default().rootContext()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        window.makeKeyAndVisible()
        self.window = window
        
        BBAnalytics.startSession()
        
        application.beginReceivingRemoteControlEvents()
        
        return true
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        super.remoteControlReceived(with: event)
        
        guard let subtype = event?.subtype else {
            return
        }
        
        switch(subtype) {
            case .remoteControlPlay:
                BBAudioManager.default().paused = false
            
            case .remoteControlPause, .remoteControlStop:
                BBAudioManager.default().paused = true
            
            case .remoteControlTogglePlayPause:
                BBAudioManager.default().togglePlayPause()
            
            case .remoteControlNextTrack:
                BBAudioManager.default().playNext()
            
            case .remoteControlPreviousTrack:
                BBAudioManager.default().playPrev()
            
            case .remoteControlEndSeekingBackward, .remoteControlEndSeekingForward: ()
//                println(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
            
            default: ()
        }
    }
}
