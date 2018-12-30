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
					
				} else {
					
				}
			}
		}
	}
}
