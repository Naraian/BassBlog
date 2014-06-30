//
//  BBAppDelegateSwift.swift
//  BassBlog
//
//  Created by Nikita Ivaniushchenko on 6/3/14.
//  Copyright (c) 2014 BassBlog. All rights reserved.
//

import UIKit

@UIApplicationMain
class BBAppDelegateSwift: UIResponder, UIApplicationDelegate
{
    var window : UIWindow!;
    
    init()
    {
        
    }
    
    class var rootViewController : BBRootViewController
    {
        get
        {
            return self.instance.window.rootViewController as BBRootViewController;
        }
    }
    
    class var instance : BBAppDelegateSwift
    {
        get
        {
            return UIApplication.sharedApplication().delegate as BBAppDelegateSwift;
        }
    }
    
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool
    {
        BBModelManager.defaultManager().rootContext();
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds);
        self.window.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() as UIViewController;
        
        self.window.makeKeyAndVisible();
        
        BBAnalytics.startSession();
        
        return true
    }
}
