//
//  commentHelper.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
class CommentHelper {
	private var coreDataStack:CoreDataStack!
	init(coreDataStack: CoreDataStack) {
		self.coreDataStack = coreDataStack
	}

	func saveComment(from data: Data) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newComment(jsonObject: jsonDictionary)
		}
		coreDataStack.saveContext()
	}
	private func newComment(jsonObject: [String:Any]) {
		let comment = Comment(context: coreDataStack.managedContext)
		let id = jsonObject["id"] as? NSNumber
		comment.id = id!.int32Value
		if let postId = jsonObject["post"] as? NSNumber {
		comment.post = PostHelper.findPostById(id: postId, context: coreDataStack.managedContext)
		}
		let parentId = jsonObject["peont"] as? NSNumber
		if parentId!.intValue != 0 {
			comment.parent = CommentHelper.findCommentById(id: parentId!, context: coreDataStack.managedContext)
		}
		comment.author_name = jsonObject["author_name"] as? String
	comment.date_gmt = convertDate(from: jsonObject["date_gmt"] as! String)
		let contentDict = jsonObject["content"] as! [String:Any]
		comment.content = contentDict["rendered"] as? String
	}
	static func findCommentById(id: NSNumber, context: NSManagedObjectContext) -> Comment? {
		let predicate = NSPredicate(format: "%K == %@", #keyPath(Comment.id), id.int32Value)
		let fetchRequest = NSFetchRequest<Comment>(entityName: "Comment")
		fetchRequest.resultType = .managedObjectResultType
		fetchRequest.predicate = predicate
		do {
			let comments = try context.fetch(fetchRequest)
			return comments.first
		} catch let error as NSError {
			print("couldn't fetch \(error) \(error.userInfo)")
			return nil
		}
	}
	private func convertDate(from dateString: String) -> NSDate? {
		let dateFormatter:DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		let date = dateFormatter.date(from: dateString)
		if let date = date {
			return NSDate(timeIntervalSince1970: date.timeIntervalSince1970)
		} else {
			return nil
		}
	}
}
