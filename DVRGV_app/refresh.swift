//
//  refresh.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 07/02/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import Foundation

class Refresh {
	private let coreDataStack:CoreDataStack
	init(coreDataStack:CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	func refreshAll() {
		Category.refreshCategories(coreDataStack: coreDataStack, isPartialRefresh: false)
		User.refreshUsers(coreDataStack:  coreDataStack, isPartialRefresh: false)
		UserDefaults.standard.set(Date(), forKey: "lastLaunch")
		Post.refreshPosts(coreDataStack: coreDataStack, lastRefresh: nil)
		Comment.refreshComment(coreDataStack: coreDataStack, lastRefresh: nil)
		self.coreDataStack.saveContext()
		UserDefaults.standard.set(Date(), forKey: "lastRefresh")
	}
	
	func partialRefresh() {
		let lastRefresh = UserDefaults.standard.object(forKey: "lastRefresh") as! Date
		Category.refreshCategories(coreDataStack: coreDataStack, isPartialRefresh: true)
		User.refreshUsers(coreDataStack: coreDataStack, isPartialRefresh: true)
		Post.refreshPosts(coreDataStack: coreDataStack, lastRefresh: lastRefresh)
		Comment.refreshComment(coreDataStack: coreDataStack, lastRefresh: lastRefresh)
		self.coreDataStack.saveContext()
		UserDefaults.standard.set(Date(), forKey: "lastRefresh")
	}
}
