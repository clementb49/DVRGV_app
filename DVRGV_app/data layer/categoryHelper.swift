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
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}
	func saveCategories(from data:Data) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newCategory(jsonObject: jsonDictionary)
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
			guard let parent=parent, let parentCategory = CategoryHelper.findCategoryById(id: parent, context: coreDataStack.managedContext) else {
				return
			}
			category.parent = parentCategory
		}
	}
	static func findCategoryById(id:NSNumber, context:NSManagedObjectContext) -> Category? {
		let predicate:NSPredicate = NSPredicate(format: "%K == %@", #keyPath(Category.id), id.int32Value)
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
