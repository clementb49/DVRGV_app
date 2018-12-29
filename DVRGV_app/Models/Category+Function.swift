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
	private static var totalPages:Int = 1
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

	private static func retrievePageCategories(group: DispatchGroup, coreDataStack:CoreDataStack, page:Int) {
		group.enter()
		let apiManager = APIManager()
		let argument:[String:String] = ["orderby":"id","per_page":"50","order":"desc","page":"\(page)"]
		let request = apiManager.request(methods: .GET, route: .categories, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error, \(error)")
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					Category.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					Category.convertCategories(from: databody!, context: coreDataStack.privateContext)
				} else {
					print("error")
				}
			}
			group.leave()
		}
		task.resume()
	}
	static func retrieveCategories(coreDataStack:CoreDataStack) {
		var currentPage = 1
		Category.totalPages = 1
		let categoryGroup = DispatchGroup()
		while(currentPage <= Category.totalPages) {
			Category.retrievePageCategories(group: categoryGroup, coreDataStack: coreDataStack, page: currentPage)
			categoryGroup.wait()
			currentPage+=1
		}
	}
}
