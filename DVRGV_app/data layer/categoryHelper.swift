//
//  categoryHelper.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
class CategoryHelper {
	private var coreDataStack:CoreDataStack!
	private var parentDict = [String:Int]()
	private let apiManager = APIManager()
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	func retrieveCategories() {
		let argument:[String:String] = ["orderby":"id","per_page":"100","order":"desc"]
		let request = apiManager.request(methods: .GET, route: .categories, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error, \(error)")
			} else {
				let responseCode = (response as! HTTPURLResponse).statusCode
				if responseCode == 200 {
					self.saveCategories(from: databody!)
				} else {
					print("error")
				}
			}
		}
		task.resume()
	}

	func saveCategories(from data:Data) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newCategory(jsonObject: jsonDictionary)
		}
		coreDataStack.saveContext()
		for (key, value) in parentDict {
			let predicateName = NSPredicate(format: "%K == %@", #keyPath(Category.name), key)
			let category = CategoryHelper.findCategory(predicate: predicateName, context: coreDataStack.managedContext)
			if let category = category {
				let predicateId = NSPredicate(format: "%K == \(value)", #keyPath(Category.id))
				category.parent = CategoryHelper.findCategory(predicate: predicateId, context: coreDataStack.managedContext)
			}
		}
		coreDataStack.saveContext()
	}
	private func newCategory(jsonObject: [String:Any]) {
		let category = Category(context: coreDataStack.managedContext)
		let id = jsonObject["id"] as? NSNumber
		category.id = id!.int32Value
		let count = jsonObject["count"] as? NSNumber
			category.count = count!.int32Value
		category.desc = jsonObject["description"] as? String
		category.name = jsonObject["name"] as? String
		let parent = jsonObject["parent"] as? NSNumber
		if (parent!.intValue != 0) {
			parentDict[category.name!] = parent!.intValue
		}
	}
	static func findCategory(predicate:NSPredicate, context:NSManagedObjectContext) -> Category? {
		let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
		fetchRequest.resultType = .managedObjectResultType
		fetchRequest.predicate = predicate
		do {
			let categories = try context.fetch(fetchRequest)
			return categories.first
		} catch let error as NSError {
			print("couldn't fetch \(error) \(error.userInfo)")
			return nil
		}
	}

}
