//
//  AppDelegate.swift
//  xkcd webcomics
//
//  Created by Jack Cook on 11/29/14.
//  Copyright (c) 2014 CosmicByte. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
            var settings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge), categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
        }
        
        application.applicationIconBadgeNumber = 0
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 0
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = "\(deviceToken)".stringByReplacingOccurrencesOfString(" ", withString: "", options: nil, range: nil).stringByReplacingOccurrencesOfString("<", withString: "", options: nil, range: nil).stringByReplacingOccurrencesOfString(">", withString: "", options: nil, range: nil)
        
        var url = NSURL(string: "http://api.cosmicbyte.com/xkcd/submit_token.php?token=\(token)")!
        var request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        nc.postNotificationName(loadFromNotificationNotification, object: nil)
    }
}
