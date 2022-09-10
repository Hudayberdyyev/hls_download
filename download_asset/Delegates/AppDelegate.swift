//
//  AppDelegate.swift
//  download_asset
//
//  Created by design on 15.08.2022.
//

import UIKit
import CoreData
import os.log

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        
//        SessionManager.shared.restoreDownloadTasksFromCoreData()
//        SessionManager.shared.downloadTasksCount()
//        SessionManager.shared.restoreDownloadsMap()
        
        if #available(iOS 13.0, *) {
            /// Scene delegate handle it
        } else {
            /// window = UIWindow(frame: UIScreen.main.bounds)
            let vc = ViewController()
            window?.rootViewController = UINavigationController(rootViewController: vc)
            window?.makeKeyAndVisible()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        SessionManager.shared.restoreDownloadsMap()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        os_log("%@ => %@", log: OSLog.viewCycle, type: .info, #fileID, #function)
        self.saveContext()
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Belet_Films")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

