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
	static func refreshComment(coreDataStack:CoreDataStack, lastRefresh:Date?) {
		Comment.totalPages = 1
		var currentPage = 1
		let commentGroup = DispatchGroup()
		while (currentPage <= Comment.totalPages) {
			Comment.retrievePageComment(group: commentGroup, coreDataStack: coreDataStack, page: currentPage, lastRefresh: lastRefresh)
			commentGroup.wait()
			currentPage+=1
		}
	}
	private static func retrievePageComment(group:DispatchGroup, coreDataStack:CoreDataStack, page:Int, lastRefresh:Date?) {
		group.enter()
		let apiManager = APIManager()
		var argument:[String:String] = ["per_page":"50","page":"\(page)"]
		if let lastRefresh = lastRefresh {
			argument["after"] = lastRefresh.iso8601
		}
		let request = apiManager.request(methods: .GET, route: .comments, data: argument)
		let task = URLSession.shared.dataTask(with: request) {dataBody, response, error -> Void in
			if let error = error {
				print(error)
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					Comment.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					let totalItem = Int(response.allHeaderFields["X-WP-Total"] as! String)!
					if totalPages != 0 && totalItem != 0 {
						Comment.converteComments(from: dataBody!, context: coreDataStack.privateContext)
					}
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
		let existingCommentIds = Comment.findAllIds(context: context)
		var parentDict = [Int32:Int32]()
		for jsonDictionary in jsonArray {
			let parent:[Int32:Int32]? = Comment.newComment(jsonObject: jsonDictionary, context: context, existingCommentIds: existingCommentIds!)
			if let parent = parent {
				parentDict = parentDict.merging(parent)
				{(_, new) in new}
			}
		}
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
	private static func newComment(jsonObject:[String:Any], context:NSManagedObjectContext, existingCommentIds:[Int]) -> [Int32:Int32]? {
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
		var comment:Comment?
		if existingCommentIds.contains(id.intValue) {
			let predicate = NSPredicate(format: "%K == \(id.int32Value)", #keyPath(Comment.id))
			comment = Comment.findComment(predicate: predicate, context: context)
		} else {
			comment = Comment(context: context)
			comment?.id = id.int32Value
		}
		let postPredicate = NSPredicate(format: "%K == \(postId.int32Value)", #keyPath(Post.id))
		if let post = Post.findPost(predicate: postPredicate, context: context) {
			comment?.post = post
		}
		if authorId.intValue != 0 {
			let authorPredicate = NSPredicate(format: "%K == \(authorId.int32Value)", #keyPath(User.id))
			if let user = User.findUser(predicate: authorPredicate, context: context) {
				comment?.author = user
			}
		}
		comment?.authorName = authorName
		comment?.date_gmt = Comment.convertDate(from: date)!
		let contentData = content.data(using: .utf8)!

		let options: [NSAttributedString.DocumentReadingOptionKey:Any] = [
			.documentType: NSAttributedString.DocumentType.html,
			.characterEncoding:String.Encoding.utf8.rawValue
		]
		if let contentAttributedString = try? NSAttributedString(data: contentData, options: options, documentAttributes: nil) {
			comment?.content = contentAttributedString
		}
		if parentId.intValue != 0 {
			if existingCommentIds.contains(id.intValue) {
				return nil
			} else {
				return [id.int32Value:parentId.int32Value]
			}
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
		fetchRequest.fetchLimit = 1
		fetchRequest.includesPendingChanges=true
		do {
			let comments = try context.fetch(fetchRequest)
			return comments.last
		} catch let error as NSError {
			print("couldn't fetch \(error) \(error.userInfo)")
			return nil
		}
	}
	
	private static func findAllIds(context:NSManagedObjectContext) -> [Int]? {
	let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
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


