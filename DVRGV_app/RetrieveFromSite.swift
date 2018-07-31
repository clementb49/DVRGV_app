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
		let categoryHelper = CategoryHelper(coreDataStack: coreDataStack)
		categoryHelper.retrieveCategories()
		let userHelper = UserHelper(coreDataStack: coreDataStack)
		userHelper.retrieveUsers()
	}
}
