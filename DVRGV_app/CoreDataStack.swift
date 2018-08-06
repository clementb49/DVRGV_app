//
//  CoreDataStack.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 26/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
	private let modelName:String
	init(modelName:String) {
		self.modelName = modelName
	}
	
	private lazy var managedContext:NSManagedObjectContext = {
		return self.storeContainer.viewContext
	}()

	lazy var privateContext:NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.parent = self.managedContext
		return context
	}()
	lazy var mainContext:NSManagedObjectContext = {
		let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.parent = self.managedContext
		return context
	}()
	
	private lazy var storeContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: self.modelName)
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error as NSError? {
				print("Unresolved error \(error), \(error.userInfo)")
			}
		}
		return container
	}()
	
	func saveContext () {
		guard managedContext.hasChanges else { return }
		do {
			try managedContext.save()
		} catch let error as NSError {
			print("Unresolved error \(error), \(error.userInfo)")
		}
	}
}
