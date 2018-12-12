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
	private var parentDict = [String:Int]()
	func retrieveCategories(group: DispatchGroup?, context:NSManagedObjectContext) {
		let apiManager = APIManager()
		group?.enter()
		let argument:[String:String] = ["orderby":"id","per_page":"100","order":"desc"]
		let request = apiManager.request(methods: .GET, route: .categories, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error, \(error)")
			} else {
				let responseCode = (response as! HTTPURLResponse).statusCode
				if responseCode == 200 {
					self.convertCategories(from: databody!, context: context)
				} else {
					print("error")
				}
			}
			group?.leave()
		}
		task.resume()
	}

	func convertCategories(from data:Data, context:NSManagedObjectContext) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newCategory(jsonObject: jsonDictionary, context: context)
		}
		save(context: context)
		for (key, value) in parentDict {
			let predicateName = NSPredicate(format: "%K == %@", #keyPath(Category.name), key)
			let category = CategoryHelper.findCategory(predicate: predicateName, context: context)
			if let category = category {
				let predicateId = NSPredicate(format: "%K == \(value)", #keyPath(Category.id))
				category.parent = CategoryHelper.findCategory(predicate: predicateId, context: context)
			}
		}
		save(context: context)
	}
	private func newCategory(jsonObject: [String:Any], context: NSManagedObjectContext) {
		let category = Category(context: context)
		guard let id = jsonObject["id"] as? NSNumber,
		let count = jsonObject["count"] as? NSNumber,
		let description = jsonObject["description"] as? String,
		let name = jsonObject["name"] as? String,
			let parent = jsonObject["parent"] as? NSNumber else {
				return
		}
		category.name = name
		category.id = id.int32Value
		category.desc = description
		category.count = count.int32Value
		if (parent.intValue != 0) {
			parentDict[category.name] = parent.intValue
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
	private func save(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
}
