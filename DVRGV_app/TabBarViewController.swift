//
//  TabBarViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 06/10/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
	var coreDataStack:CoreDataStack!
	var viewIsLoading:Bool?
    override func viewDidLoad() {
		super.viewDidLoad()
		delegate = self
	}

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		let navController = viewController as! UINavigationController
		let vc = navController.topViewController as! ListPostTableViewController
		vc.coreDataStack = self.coreDataStack
	}
	
	func didFinishFirstLaunch() {
		guard let vcs = viewControllers,
			let navController = vcs[0] as? UINavigationController,
			let vc = navController.topViewController as? ListPostTableViewController else {
			return
		}
		vc.coreDataStack = self.coreDataStack
		self.viewIsLoading = false
		vc.viewIsLoading = self.viewIsLoading
		vc.updatePostCategory()
		vc.updateUI()
		vc.tableView.reloadData()
	}


	func launch() {
		guard let vcs = viewControllers,
			let navController = vcs[0] as? UINavigationController,
			let vc = navController.topViewController as? ListPostTableViewController else {
			return
		}
		if viewIsLoading ?? false {
			tabBar.isUserInteractionEnabled = false
			vc.viewIsLoading = self.viewIsLoading
			vc.coreDataStack = self.coreDataStack
		} else {
			vc.viewIsLoading = self.viewIsLoading
			vc.coreDataStack = coreDataStack
		}
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
