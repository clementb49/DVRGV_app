//
//  PostHelper.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 30/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import CoreData
import SwiftSoup

extension Post {
	private static var totalPages:Int = 1
	static func refreshPosts(coreDataStack:CoreDataStack, lastRefresh:Date?) {
		Post.totalPages = 1
		var currentPage:Int = 1
		let postGroup = DispatchGroup()
		while (currentPage<=Post.totalPages) {
			Post.retrievePagePosts(group: postGroup, coreDataStack: coreDataStack, page: currentPage, lastRefresh: lastRefresh)
			postGroup.wait()
			currentPage = currentPage + 1
		}
	}
	private static func retrievePagePosts(group: DispatchGroup, coreDataStack: CoreDataStack, page: Int, lastRefresh:Date?) {
		group.enter()
		let apiManager = APIManager()
		var argument = ["per_page":"50","page":"\(page)"]
		if let lastRefresh = lastRefresh {
			argument["after"] = lastRefresh.iso8601
		}
		let request = apiManager.request(methods: .GET, route: .posts, data: argument)
		let task = URLSession.shared.dataTask(with: request) {dataBody, response, error -> Void in
			if let error = error {
				print("errror \(error)")
			} else {
				let response = response as! HTTPURLResponse
				if response.statusCode == 200 {
					Post.totalPages = Int(response.allHeaderFields["X-WP-TotalPages"] as! String)!
					let totalItem = Int(response.allHeaderFields["X-WP-Total"] as! String)!
					if totalPages != 0 && totalItem != 0 {
						Post.convertPost(from: dataBody!, context: coreDataStack.privateContext)
					}
				} else {
					print("errror")
				}
			}
			group.leave()
		}
		task.resume()
	}
	private static func convertPost(from data:Data, context: NSManagedObjectContext) {
		guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
			let jsonArray = jsonObject as? [[String:Any]] else {
				return
		}
		let idArray:[Int]? = Post.findAllIds(context: context)
		for jsonDictionary in jsonArray {
			Post.newPost(jsonObject: jsonDictionary, context: context, existingPostIds: idArray!)
		}
		Post.saveContext(context: context)
	}
	private static func newPost(jsonObject: [String:Any], context: NSManagedObjectContext, existingPostIds:[Int]) {
		guard let id = jsonObject["id"] as? NSNumber,
			let date = jsonObject["date_gmt"] as? String,
			let modified = jsonObject["modified_gmt"] as? String,
			let link = jsonObject["link"] as? String,
			let titleDict = jsonObject["title"] as? [String:Any],
			let title = titleDict["rendered"] as? String,
			let contentDict = jsonObject["content"] as? [String:Any],
			let author = jsonObject["author"] as? NSNumber,
			let categoriesArray = jsonObject["categories"] as? [NSNumber],
			let contentString = contentDict["rendered"] as? String else {
				return
		}
		var post:Post?
		if existingPostIds.contains(id.intValue) {
			let predicate = NSPredicate(format: "%K == \(id.int32Value)", #keyPath(Post.id))
			post = findPost(predicate: predicate, context: context)!
		} else {
			post = Post(context: context)
			post?.id = id.int32Value
		}
		post?.date_gmt = Post.convertDate(from: date)
		post?.modified_gmt = Post.convertDate(from: modified)
		post?.link = link
		post?.title = String(htmlEncodedString: title)

		post?.author = User.findUser(predicate: NSPredicate(format: "%K == \(author.int32Value)", #keyPath(User.id)), context: context)
		let HTMLString = Post.newHTMLString(contentString)
		do {
			let doc:Document = try parse(HTMLString)
			let podcastURL = Post.findPodcastURL(doc: doc)
			if let podcastURL = podcastURL {
				let podcast = Podcast(context: context)
				podcast.audioURL = podcastURL
				podcast.imageURL = Post.findFirstImageURL(doc: doc)
				post?.podcast = podcast
				post?.content = Post.deletePlayer(doc: doc)
			} else {
				post?.content = HTMLString
			}
		} catch Exception.Error(type: let type, Message: let message) {
			print(type)
			print(message)
		} catch {
			print("failed to parse the HTML String")
		}
		post?.commentIsOpen = jsonObject["comment_status"] as! String == "open"
		for categoryId in categoriesArray {
			let predicate = NSPredicate(format: "%K == \(categoryId)", #keyPath(Category.id))
			if let category = Category.findCategory(predicate:predicate, context: context) {
				post?.addToCategories(category)
			}
		}
	}
	private static func newHTMLString(_ contentString: String) -> String {
		var string = "<!doctype html><html><head></head><body>"
		string = string + contentString
		string = string + "</body></html>"
		return string
	}
	private static func convertDate(from dateString: String) -> Date? {
		let dateFormatter:DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		return dateFormatter.date(from: dateString)
	}
	static func findPost(predicate: NSPredicate, context: NSManagedObjectContext) -> Post? {
		let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
		fetchRequest.resultType = .managedObjectResultType
		fetchRequest.predicate = predicate
		fetchRequest.fetchLimit = 1
		do {
			let posts = try context.fetch(fetchRequest)
			return posts.last
		} catch let error as NSError {
			print("couldn't fetch \(error) \(error.userInfo)")
			return nil
		}
	}
	static func fetchPost(context:NSManagedObjectContext) -> [Post]? {
		let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
		fetchRequest.resultType = .managedObjectResultType
		do {
			return try? context.fetch(fetchRequest)
		}
	}
	private static func saveContext(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
	private static func findPodcastURL(doc:Document) -> URL? {
		do {
			let link:Element? = try doc.select("a[href$=.mp3]").first()
			let urlString = try link?.attr("href")
			if let urlString = urlString {
				return URL(string: urlString)
			} else {
				return nil
			}
		} catch {
			print("failed to find podcast url")
			return nil
		}
	}
	private static func deletePlayer(doc: Document) -> String? {
		do {
			let playerElements:Elements = try doc.getElementsByClass("powerpress_player")
			try playerElements.remove()
			let podcastLinkElements:Elements = try doc.getElementsByClass("powerpress_links powerpress_links_mp3")
			try podcastLinkElements.remove()
			let htmlString = try doc.outerHtml()
			return htmlString
		} catch {
			print("failed to delete the player")
			return "unable to delete the player"
		}
	}
	private static func findFirstImageURL(doc:Document) -> URL? {
		do {
			let image:Element? = try doc.select("img").first()
			let imageURLString = try image?.attr("src")
			if let imageURLString = imageURLString {
				return URL(string: imageURLString)
			} else {
				return nil
			}
		} catch {
			print("failed to find the first image url")
			return nil
		}
	}
	private static func findAllIds(context:NSManagedObjectContext) -> [Int]? {
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
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

