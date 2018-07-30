//
//  UserHelper.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
class UserHelper {
	private var coreDataStack:CoreDataStack!
	init(coreDataStack: CoreDataStack) {
	self.coreDataStack = coreDataStack
	}
	func saveUser(from data: Data) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newUser(jsonObject: jsonDictionary)
		}
		coreDataStack.saveContext()
	}
	private func newUser(jsonObject: [String:Any]) {
		let user = User(context: coreDataStack.managedContext)
		let id = jsonObject["id"] as? NSNumber
		user.id = id!.int32Value
		user.name = jsonObject["name"] as? String

	}
	static func findUserById(id: NSNumber, context:NSManagedObjectContext) -> User? {
		let predicate:NSPredicate = NSPredicate(format: "%K == %@", #keyPath(User.id), id.int32Value)
		let fetchRequest = NSFetchRequest<User>(entityName: "User")
		fetchRequest.resultType = .managedObjectResultType
		fetchRequest.predicate = predicate
		do {
			let users = try context.fetch(fetchRequest)
			return users.first
		} catch let error as NSError {
			print("couldn't fetch \(error) \(error.userInfo)")
			return nil
		}
	}
}
