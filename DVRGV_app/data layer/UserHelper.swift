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
	private let apiManager = APIManager()
	func retrieveUsers(group: DispatchGroup?, context: NSManagedObjectContext) {
		group?.enter()
		let argument = ["orderby":"id","per_page":"100"]
		let request = apiManager.request(methods: .GET, route: .users, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error \(error)")
			} else {
				let responseCode = (response as! HTTPURLResponse).statusCode
				if responseCode == 200 {
					self.convertUser(from: databody!, context: context)
				} else {
					print("error")
				}
			}
			group?.leave()
		}
		task.resume()
	}
	func convertUser(from data: Data, context: NSManagedObjectContext) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newUser(jsonObject: jsonDictionary, context: context)
		}
		saveContext(context: context)
	}
	private func newUser(jsonObject: [String:Any], context: NSManagedObjectContext) {
		let user = User(context: context)
		let id = jsonObject["id"] as? NSNumber
		user.id = id!.int32Value
		user.name = jsonObject["name"] as? String
	}
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
	private func saveContext(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
}
