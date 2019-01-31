//
//  DetailArticleViewController.swift
//  DVRGV_app
//
//  Created by clément boussiron on 10/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import WebKit
class DetailArticleViewController: UIViewController {
	var posts:[Post]?
	var currentPostIndex:Int?
	var currentPost:Post?
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var dateLabel:UILabel!

	@IBOutlet weak var webView: WKWebView!
	
	@IBOutlet weak var commentButton: UIBarButtonItem!
	override func viewDidLoad() {
        super.viewDidLoad()
		updateUI()
    }
	
	func updateUI() {
		updateCurrentPost()
		guard let currentPost = self.currentPost,
			let postCategories = currentPost.categories,
			let postDate = currentPost.date_gmt,
			let postContent = currentPost.content,
			let postTitle = currentPost.title,
			let postAuthor = currentPost.author,
		let postLink = currentPost.link else {
				return
		}
		webView.loadHTMLString(postContent, baseURL: postLink)
		let categoriesArray = Array(postCategories)
		categoryLabel.text = categoriesArray.last?.name
		titleLabel.text = postTitle
		authorLabel.text = postAuthor.name
		dateLabel.text = DateFormatter.localizedString(from: postDate, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
		if currentPost.commentIsOpen == true, let numberComment = currentPost.comments?.count {
			commentButton.isEnabled = true
			if numberComment == 0 || numberComment == 1 {
				commentButton.title = "\(numberComment) commentaire"
			} else {
				commentButton.title = "\(numberComment) commentaires"
			}
		} else {
			commentButton.isEnabled = false
		}
	}

	private func updateCurrentPost() {
		guard let posts = self.posts,
			let curentPostIndex = self.currentPostIndex else {
				return
		}
		self.currentPost = posts[curentPostIndex]
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "detailArticleViewControllerToCommentCollectionViewController" {
			guard let destinationViewController = segue.destination as? CommentCollectionViewController,
				let currentPost = self.currentPost,
				let comments = currentPost.comments else {
					return
			}
			destinationViewController.currentPost = self.currentPost
			destinationViewController.comments = Array(comments)
		}
	}
	

}
