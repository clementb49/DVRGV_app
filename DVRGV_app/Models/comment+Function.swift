//
//  comment+Function.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
extension Comment {
	private static var totalPages:Int = 1
	static func retrieveComment(coreDataStack:CoreDataStack) {
		Comment.totalPages = 1
		var currentPage = 1
		let commentGroup = DispatchGroup()
		while (currentPage <= Comment.totalPages) {
			Comment.retrievePageComment(group: commentGroup, coreDataStack: coreDataStack, page: currentPage)
			commentGroup.wait()
			currentPage+=1
		}
	}
	private static func retrievePageComment(group:DispatchGroup, coreDataStack:CoreDataStack, page:Int) {
		group.enter()
		let apiManager = APIManager()
		let argument:[String:String] = ["per_page":"50","page":"\(page)"]
		let request = apiManager.request(methods: .GET, route: .comments, data: argument)
		let task = URLSession.shared.dataTask(with: request) {dataBody, response, error -> Void in
			if let error = error {
				print(error)
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					Comment.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					Comment.converteComments(from: dataBody!, context: coreDataStack.privateContext)
				} else {
					print("error")
				}
			}
			group.leave()
		}
		task.resume()
	}
	private static func converteComments(from data:Data, context:NSManagedObjectContext) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let jsonArray = jsonObject as? [[String:Any]] else {
				return
		}
		var parentDict = [Int32:Int32]()
		for jsonDictionary in jsonArray {
			let parent:[Int32:Int32]? = Comment.newComment(jsonObject: jsonDictionary, context: context)
			if let parent = parent {
				parentDict = parentDict.merging(parent)
				{(_, new) in new}
			}
		}
		Comment.save(context: context)
		for (child, parent) in parentDict {
			let childPredicate = NSPredicate(format: "%K == \(child)", #keyPath(Comment.id))
			let parentPredicate = NSPredicate(format: "%K == \(parent)", #keyPath(Comment.id))
			guard let childComment = Comment.findComment(predicate:  childPredicate, context: context),
				let parentComment = Comment.findComment(predicate:  parentPredicate, context: context) else {
					continue
			}
			childComment.parent = parentComment
		}
		Comment.save(context: context)
	}
	private static func newComment(jsonObject:[String:Any], context:NSManagedObjectContext) -> [Int32:Int32]? {
		let comment = Comment(context: context)
		guard let id = jsonObject["id"] as? NSNumber,
			let postId = jsonObject["post"] as? NSNumber,
			let parentId = jsonObject["parent"] as? NSNumber,
			let authorId = jsonObject["author"] as? NSNumber,
			let authorName = jsonObject["author_name"] as? String,
			let date = jsonObject["date_gmt"] as? String,
			let contentDict = jsonObject["content"] as? [String:Any],
			let content = contentDict["rendered"] as? String else {
				print("error json")
				return nil
		}
		comment.id = id.int32Value
		let postPredicate = NSPredicate(format: "%K == \(postId.int32Value)", #keyPath(Post.id))
		if let post = Post.findPost(predicate: postPredicate, context: context) {
			comment.post = post
		}
		if authorId.intValue != 0 {
			let authorPredicate = NSPredicate(format: "%K == \(authorId.int32Value)", #keyPath(User.id))
			if let user = User.findUser(predicate: authorPredicate, context: context) {
				comment.author = user
			}
		}
		comment.authorName = authorName
		comment.date_gmt = Comment.convertDate(from: date)
		
		if parentId.intValue != 0 {
			return [id.int32Value:parentId.int32Value]
		} else {
			return nil
		}
	}
	private static func convertDate(from dateString: String) -> Date? {
		let dateFormatter:DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter.date(from: dateString)
	}
	private static func save(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
	static func findComment(predicate:NSPredicate, context:NSManagedObjectContext) -> Comment? {
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
}
