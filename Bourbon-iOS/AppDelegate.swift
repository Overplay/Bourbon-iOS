//
//  AppDelegate.swift
//  Belashi-iOS
//
//  Created by Mitchell Kahn on 7/13/16.
//  Copyright © 2016 AppDelegates. All rights reserved.
//

import UIKit
import PromiseKit
import SystemConfiguration
import XCGLogger

let log = XCGLogger.default

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var reachability: NetworkReachability?
    
    func handle403(){
        Settings.sharedInstance.userBelliniJWT = nil;
        var mainView: UIStoryboard!
        mainView = UIStoryboard(name: "RegistrationStoryboard", bundle: nil)
        let viewcontroller : UIViewController = mainView.instantiateViewController(withIdentifier: "LoginOrRegisterVC") as UIViewController
        self.window!.rootViewController = viewcontroller
    }
    
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        log.setup(level: .debug,
                  showThreadName: true,
                  showLevel: true,
                  showFileNames: true,
                  showLineNumbers: true,
                  writeToFile: nil,
                  fileLevel: .debug)
        
        Settings.sharedInstance.registerDefaults()
        
        // Log into Bellini/OGCloud if possible
        _ = OGCloud.sharedInstance
        
//        OGCloud.sharedInstance.login("mitcha@ourglass.tv", password: "D@rkB0ck")
//            .then{ jsonData in
//                log.debug("logged in")
//            }
//            .catch{ err in
//                log.debug("Shit da bed")
//            }

        // Setup some universal style things
        UITextField.appearance().keyboardAppearance = .dark

        // Register to shove the user to login when a 403 occurs.
        NotificationCenter.default
            .addObserver(forName:Notification.Name(rawValue:"error403"),
                       object:nil, queue:nil) { notification in
                            self.handle403()
                        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        reachability?.stopListening()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Fire it up when we foreground
        reachability = NetworkReachability.sharedInstance
        reachability?.startListening()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

