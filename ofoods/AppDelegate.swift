//
//  AppDelegate.swift
//  ofoods
//
//  Created by Nhung Nguyen on 21/4/2023.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var databaseController: DatabaseProtocol?
    let userDefaults = UserDefaults.standard
    let UOM_DEFAULTS = ["serving", "tsp", "tbsp", "gram", "oz", "litre", "cup", "slice", "pinch", "fruit"]
    let UOM_KEY = "ingredientUnits"

//    var persistentContainer: NSPersistentContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        persistentContainer = NSPersistentContainer(name: "ImageModel")
//        persistentContainer?.loadPersistentStores() { (description, error) in
//            if let error = error {
//                fatalError("Failed to load CoreData stack with error: \(error)")
//            }
//        }
        databaseController = DatabaseController()
        userDefaults.set(UOM_DEFAULTS, forKey: UOM_KEY)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

