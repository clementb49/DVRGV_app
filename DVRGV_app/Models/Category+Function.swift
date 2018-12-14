//
//  Category+Function.swift
//  DVRGV_app
//
//  Created by clément boussiron on 12/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
extension Category {
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
	private static func save(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}

	private static func newCategory(jsonObject: [String:Any], context: NSManagedObjectContext) -> [String:Int]? {
		let category = Category(context: context)
		guard let id = jsonObject["id"] as? NSNumber,
			let count = jsonObject["count"] as? NSNumber,
			let description = jsonObject["description"] as? String,
			let name = jsonObject["name"] as? String,
			let parent = jsonObject["parent"] as? NSNumber else {
				return nil
		}
		category.name = name
		category.id = id.int32Value
		category.desc = description
		category.count = count.int32Value
		if (parent.intValue != 0) {
			return [category.name:parent.intValue]
		} else {
			return nil
		}
	}
	private static func convertCategories(from data:Data, context:NSManagedObjectContext) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let jsonArray = jsonObject as? [[String:Any]] else {
				return
		}
		var parentDict:[String:Int] = [String:Int]()
		for jsonDictionary in jsonArray {
			let parent:[String:Int]? = Category.newCategory(jsonObject: jsonDictionary, context: context)
			if let parent = parent {
				parentDict = parentDict.merging(parent)
					{(_, new) in new}
			}
		}
		Category.save(context: context)
		for (key, value) in parentDict {
			let predicateName = NSPredicate(format: "%K == %@", #keyPath(Category.name), key)
			let category = Category.findCategory(predicate: predicateName, context: context)
			if let category = category {
				let predicateId = NSPredicate(format: "%K == \(value)", #keyPath(Category.id))
				category.parent = Category.findCategory(predicate: predicateId, context: context)
			}
		}
		Category.save(context: context)
	}

	static func retrieveCategories(group: DispatchGroup?, context:NSManagedObjectContext) {
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
					Category.convertCategories(from: databody!, context: context)
				} else {
					print("error")
				}
			}
			group?.leave()
		}
		task.resume()
	}

}
