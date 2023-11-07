//
//  AppDelegate.swift
//  PassplateApp
//
//  Created by Summer Ely on 10/5/23.
//

import UIKit
import FirebaseCore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // Override point for customization after application launch.
        return true
    }
    
    
    func setStyle(_ style: UIUserInterfaceStyle) {
        // Apply the user interface style to the window of the scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.overrideUserInterfaceStyle = style
            
            // Update appearance for tabBar and navigationBar
            UITabBar.appearance().tintColor = style == .dark ? .white : .systemBlue
            UINavigationBar.appearance().tintColor = style == .dark ? .white : .systemBlue
            UINavigationBar.appearance().barStyle = style == .dark ? .black : .default
            
            // Refresh the appearance of currently visible view controller
            window.rootViewController?.setNeedsStatusBarAppearanceUpdate()
            if let tabBarController = window.rootViewController as? UITabBarController {
                tabBarController.viewControllers?.forEach { viewController in
                    viewController.setNeedsStatusBarAppearanceUpdate()
                    viewController.navigationController?.navigationBar.setNeedsLayout()
                }
            }
        }
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

