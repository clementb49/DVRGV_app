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
class PostHelper {
	private let apiManager = APIManager()
	func retrievePosts(group: DispatchGroup?, context: NSManagedObjectContext, page: Int) {
		group?.enter()
		let argument = ["per_page":"10","page":"\(page)"]
		let request = apiManager.request(methods: .GET, route: .posts, data: argument)
		let task = URLSession.shared.dataTask(with: request) {dataBody, response, error -> Void in
			if let error = error {
				print("errror \(error)")
			} else {
				let responseCode = (response as! HTTPURLResponse).statusCode
				if responseCode == 200 {
					self.convertPost(from: dataBody!, context: context)
				} else {
					print("errror")
				}
			}
			group?.leave()
		}
		task.resume()
	}
	func convertPost(from data:Data, context: NSManagedObjectContext) {
		let jsonArray = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[String:Any]]
		for jsonDictionary in jsonArray {
			newPost(jsonObject: jsonDictionary, context: context)
		}
		saveContext(context: context)
	}
	private func newPost(jsonObject: [String:Any], context: NSManagedObjectContext) {
		let post = Post(context: context)
		let id = jsonObject["id"] as? NSNumber
		post.id = id!.int32Value
		post.date_gmt = convertDate(from: jsonObject["date_gmt"] as! String)
		post.modified_gmt = convertDate(from: jsonObject["modified_gmt"] as! String)
		post.link = URL(string: jsonObject["link"] as! String)
		let titleDict = jsonObject["title"] as! [String:Any]
		post.title = titleDict["rendered"] as? String
		let contentDict = jsonObject["content"] as! [String:Any]
		let contentString = contentDict["rendered"] as! String
		let HTMLString = newHTMLString(contentString)
		do {
			let doc:Document = try parse(HTMLString)
			post.podcastURL = findPodcastURL(doc: doc)
			if post.podcastURL != nil {
				post.content = deletePlayer(doc: doc)
			}
		} catch Exception.Error(type: let type, Message: let message) {
			print(message)
		} catch {
			print("failed to parse the HTML String")
		}
			let author = jsonObject["author"] as? NSNumber
		if let author = author {
			let predicate = NSPredicate(format: "%K == \(author.intValue)", #keyPath(User.id))
			post.author = UserHelper.findUser(predicate: predicate, context: context)
		}
		post.commentIsOpen = jsonObject["comment_status"] as! String == "open"
		let categoriesArray = jsonObject["categories"] as? [NSNumber]
		if let categoriesArray = categoriesArray {
			for categoryId in categoriesArray {
				let predicate = NSPredicate(format: "%K == \(categoryId.intValue)", #keyPath(Category.id))
				if let category = CategoryHelper.findCategory(predicate:predicate, context: context) {
					post.addToCategories(category)
				}
			}
		}
	}
	private func newHTMLString(_ contentString: String) -> String {
		var string = "<! doctype html><html><head></head><body>"
		string = string + contentString
		string = string + "</body></html>"
		return string
	}
	private func convertDate(from dateString: String) -> Date? {
		let dateFormatter:DateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		
		return dateFormatter.date(from: dateString)
	}
	static func findPost(predicate: NSPredicate, context: NSManagedObjectContext) -> Post? {
		let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
		fetchRequest.resultType = .managedObjectResultType
		fetchRequest.predicate = predicate
		do {
			let posts = try context.fetch(fetchRequest)
			return posts.first
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
	func saveContext(context: NSManagedObjectContext) {
		do {
			try context.save()
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
	func findPodcastURL(doc:Document) -> URL? {
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
	private func deletePlayer(doc: Document) -> String? {
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
}
