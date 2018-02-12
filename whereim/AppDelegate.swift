//
//  AppDelegate.swift
//  whereim
//
//  Created by Buganini Q on 13/02/2017.
//  Copyright © 2017 Where.IM. All rights reserved.
//

import Branch
import Firebase
import GRDB
import UIKit
import FBSDKCoreKit
import GoogleMaps
import GoogleSignIn
import Mapbox
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    let DB_FILE = "whereim.sqlite"
    var service: CoreService?
    var dbConn: DatabaseQueue?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GMSServices.provideAPIKey(Config.GOOGLE_MAP_KEY)
        MGLAccountManager.setAccessToken(Config.MAPBOX_KEY)

        UserDefaults.standard.register(defaults: [Key.POWER_SAVING: true])

        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }

        do {
            let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let db_file = folder.appendingPathComponent(DB_FILE).path
            dbConn = try DatabaseQueue(path: db_file)

            try dbConn!.inDatabase { db in
                let db_version = try Int.fetchOne(db, "PRAGMA user_version")!
                print("db_version", db_version)

                try Channel.migrate(db, db_version)
                print("Channel db migration finished")

                try Mate.migrate(db, db_version)
                print("Mate db migration finished")

                try Marker.migrate(db, db_version)
                print("Marker db migration finished")

                try Enchantment.migrate(db, db_version)
                print("Enchantment db migration finished")

                try Message.migrate(db, db_version)
                print("Message db migration finished")

                try Log.migrate(db, db_version)
                print("Log migration finished")

                print("All migration finished")

                try db.execute("PRAGMA user_version = \(Config.DB_VERSION)")
            }
        } catch {
            print("Error opening db \(error)")
        }

        service = CoreService.bind()

        let branch = Branch.getInstance()
        branch!.initSession(launchOptions: launchOptions, automaticallyDisplayDeepLinkController: true, deepLinkHandler: { params, error in
            if error == nil {
                if let link = params?["$deeplink_path"] as? String {
                    self.service!.processLink(link)
                }
            }
        })

        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if(application.applicationState == .active) {
            //app is currently active, can update badges count here

        } else if(application.applicationState == .background){
            //app is in background, if content-available key of your notification is set to 1, poll to your backend to retrieve data and update your interface here
            if let channel_id = userInfo["channel"] as? String {
                service!.set(channel_id: channel_id, unread: true)
            }
        } else if(application.applicationState == .inactive){
            //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let startupVC = sb.instantiateViewController(withIdentifier: "startup") as! UINavigationController

            if let channel_id = userInfo["channel"] as? String {
                let channel = service!.getChannel(id: channel_id)
                if channel?.enabled == true {
                    let vc = sb.instantiateViewController(withIdentifier: "channel") as! ChannelController
                    vc.channel = channel
                    if let t = userInfo["type"] as? String {
                        switch t {
                        case "text":
                            vc.defaultTab = ChannelController.TAB_MESSAGE
                        default:
                            vc.defaultTab = ChannelController.TAB_MAP
                        }
                    }
                    startupVC.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
                    startupVC.pushViewController(vc, animated: false)
                }
            }

            window?.rootViewController = startupVC;
        }
    }

    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {


        let userInfo = notification.request.content.userInfo

        let type = userInfo["type"] as? String
        let channel_id = userInfo["channel"] as? String
        let mate_id = userInfo["mate"] as? String

        service = CoreService.bind()
        var from_self = true
        var listened = false
        if channel_id != nil {
            if let channel = service!.getChannel(id: channel_id!) {
                if channel.mate_id != nil && channel.mate_id != mate_id {
                    from_self = false
                }
            }
            listened = service!.hasMessageListener(channel_id: channel_id!)
        }

        let show = channel_id == nil || type != "text" || (!from_self && !listened)

        if show {
            completionHandler([.alert, .badge, .sound])
        } else {
            completionHandler([])
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})

        var build = "release"

        #if DEBUG
            build = "debug"
        #endif

        let tk = "\(build)/\(deviceTokenString)"
        print("APNs device token: \(tk)")

        service?.setPushToken(tk)
    }

    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().handleDeepLink(url);

        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }

    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var ret = false
        ret = FBSDKApplicationDelegate.sharedInstance().application(
            app,
            open: url as URL!,
            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,
            annotation: options[UIApplicationOpenURLOptionsKey.annotation]
        )
        if !ret {
            ret = GIDSignIn.sharedInstance().handle(url,
                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplicationOpenURLOptionsKey.annotation]
            )
        }
        return ret
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        service?.enterBackground()

        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        service?.enterForeground()

        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

