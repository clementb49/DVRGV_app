//
//  RetrieveFromSite.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
class RetrieveFromSite {
	var coreDataStack:CoreDataStack!
	func retrieveAll() {
		let categoryHelper = CategoryHelper()
		categoryHelper.retrieveCategories(group: nil, context: coreDataStack.privateContext)
		let userHelper = UserHelper()
		userHelper.retrieveUsers(group: nil, context: coreDataStack.privateContext)
		let postHelper = PostHelper()
		postHelper.retrievePosts(group: nil, context: coreDataStack.privateContext)
	}
}
