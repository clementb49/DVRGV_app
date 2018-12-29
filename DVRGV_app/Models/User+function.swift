//
//  User+function.swift
//  DVRGV_app
//
//  Created by clément boussiron on 17/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
extension User {
	static var totalPages:Int = 1
	static func findUser(predicate:NSPredicate, context:NSManagedObjectContext) -> User? {
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
	private static func saveContext(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}

	private static func newUser(jsonObject: [String:Any], context: NSManagedObjectContext) {
		let user = User(context: context)
		guard let id = jsonObject["id"] as? NSNumber,
			let name = jsonObject["name"] as? String else {
			return
		}
		user.id = id.int32Value
		user.name = name
	}
	private static func convertUser(from data: Data, context: NSManagedObjectContext) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let jsonArray = jsonObject as? [[String:Any]] else {
				return
		}
		for jsonDictionary in jsonArray {
			User.newUser(jsonObject: jsonDictionary, context: context)
		}
		User.saveContext(context: context)
	}

	private static func retrievePageUsers(group: DispatchGroup, coreDataStack:CoreDataStack, page:Int) {
		group.enter()
		let apiManager = APIManager()
		let argument = ["orderby":"id","per_page":"50","page":"\(page)"]
		let request = apiManager.request(methods: .GET, route: .users, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error \(error)")
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					User.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					User.convertUser(from: databody!, context: coreDataStack.privateContext)
				} else {
					print("error")
				}
			}
			group.leave()
		}
		task.resume()
	}
	static func retrieveUsers(coreDataStack: CoreDataStack) {
	var currentPage = 1
		User.totalPages = 1
		let userGroup = DispatchGroup()
		while (currentPage <= totalPages) {
			User.retrievePageUsers(group: userGroup, coreDataStack: coreDataStack, page: currentPage)
			userGroup.wait()
			currentPage+=1
		}
	}
}
