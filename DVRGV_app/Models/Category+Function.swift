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
		fetchRequest.fetchLimit=1
		fetchRequest.includesPendingChanges=true
		do {
			let categories = try context.fetch(fetchRequest)
			return categories.last
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

	private static func newCategory(jsonObject: [String:Any], context: NSManagedObjectContext) -> [Int32:Int32]? {
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
			return [id.int32Value:parent.int32Value]
		} else {
			return nil
		}
	}
	private static func convertCategories(from data:Data, context:NSManagedObjectContext) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let jsonArray = jsonObject as? [[String:Any]] else {
				return
		}
		var parentDict:[Int32:Int32] = [Int32:Int32]()
		for jsonDictionary in jsonArray {
			let parent:[Int32:Int32]? = Category.newCategory(jsonObject: jsonDictionary, context: context)
			if let parent = parent {
				parentDict = parentDict.merging(parent)
					{(_, new) in new}
			}
		}
		for (child, parent) in parentDict {
			let childPredicate = NSPredicate(format: "%K == \(child)", #keyPath(Category.id))
			let parentPredicate = NSPredicate(format: "%K == \(parent)", #keyPath(Category.id))
			guard let childCategory = Category.findCategory(predicate: childPredicate, context: context),
				let parentCategory = Category.findCategory(predicate: parentPredicate, context: context) else {
					continue
			}
			childCategory.parent = parentCategory
		}
		Category.save(context: context)
	}

	private static func retrievePageCategories(group: DispatchGroup, coreDataStack:CoreDataStack, page:Int, isPartialRefresh:Bool) {
		group.enter()
		let apiManager = APIManager()
		var argument:[String:String] = ["orderby":"id","per_page":"50","order":"desc","page":"\(page)"]
		if isPartialRefresh {
			let idArray = Category.findAllIds(context: coreDataStack.privateContext)!
			let idString:String = idArray.map{"\($0),"}.reduce(""){$0+$1}
			argument["exclude"] = idString
		}
		let request = apiManager.request(methods: .GET, route: .categories, data: argument)
		let task = URLSession.shared.dataTask(with: request) {databody, response, error -> Void in
			if let error = error {
				print("error, \(error)")
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					Category.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					let totalItem = Int(response.allHeaderFields["X-WP-Total"] as! String)!
					if totalPages != 0 && totalItem != 0 {
						Category.convertCategories(from: databody!, context: coreDataStack.privateContext)
					}
				} else {
					print("error")
				}
			}
			group.leave()
		}
		task.resume()
	}
	static func refreshCategories(coreDataStack:CoreDataStack, isPartialRefresh:Bool) {
		var currentPage = 1
		Category.totalPages = 1
		let categoryGroup = DispatchGroup()
		while(currentPage <= Category.totalPages) {
			Category.retrievePageCategories(group: categoryGroup, coreDataStack: coreDataStack, page: currentPage, isPartialRefresh: isPartialRefresh)
			categoryGroup.wait()
			currentPage+=1
		}
	}
	private static func findAllIds(context:NSManagedObjectContext) -> [Int]? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Category")
		fetchRequest.resultType = .dictionaryResultType
		fetchRequest.propertiesToFetch = ["id"]
		fetchRequest.resultType = .dictionaryResultType
		do {
			let categories = try context.fetch(fetchRequest) as NSArray
			return categories.value(forKey: "id") as? [Int]
		} catch let error as NSError {
			print("couldn't fetc \(error), \(error.userInfo)")
			return nil
		}
	}
}
