
//
//  AppDelegate.swift
//  DVRGV_app
//
//  Created by DVRGV Team on 26/07/2018.
//  Copyright © 2018 DVRGV All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	lazy var coreDataStack:CoreDataStack = CoreDataStack(modelName: "DVRGV")

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playback, mode: .spokenAudio, options: [])
		} catch let error as NSError {
			print("failed to set theaudi session category and mode: \(error.localizedDescription)")
		}
		guard let tabController = window?.rootViewController as? TabBarViewController else {
			return true
		}
		let fetchRequestCategory = NSFetchRequest<Category>(entityName: "Category")
		let countCategory = try! coreDataStack.mainContext.count(for: fetchRequestCategory)
		if countCategory != 0 {
			tabController.coreDataStack = coreDataStack
			tabController.viewIsLoading = false
			tabController.launch()
			return true
		} else {
			tabController.viewIsLoading = true
			tabController.coreDataStack = coreDataStack
			tabController.launch()
			retrieveAll(view: tabController)
			return true
		}
	}
	
	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}
	
	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		coreDataStack.saveContext()
	}
	
	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}
	
	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}
	
	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		coreDataStack.saveContext()
	}
	
	func retrieveAll(view: TabBarViewController) {
		let work = DispatchWorkItem {
			Category.retrieveCategories(coreDataStack: self.coreDataStack)
			User.retrieveUsers(coreDataStack: self.coreDataStack)
			let postGroup = DispatchGroup()
			Post.retrievePosts(group: postGroup, coreDataStack: self.coreDataStack)
			postGroup.wait()
			self.coreDataStack.saveContext()
			DispatchQueue.main.async {
				view.didFinishFirstLaunch()
			}
		}
		DispatchQueue.global().async (execute: work)
	}
	
	func registerForPushNotifications() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {(granted, error) in print("permission granted: \(granted)")
		}
	}
}

