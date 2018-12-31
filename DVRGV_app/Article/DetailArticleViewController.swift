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
		guard let posts:[Post] = self.posts,
			let currentPostIndex = currentPostIndex,
			let categories = posts[currentPostIndex].categories,
			let date = posts[currentPostIndex].date_gmt,
			let content = posts[currentPostIndex].content else {
				return
		}
		webView.loadHTMLString(content, baseURL: posts[currentPostIndex].link)
		let categoriesArray = Array(categories)
		categoryLabel.text = categoriesArray.last?.name
		titleLabel.text = posts[currentPostIndex].title
		authorLabel.text = posts[currentPostIndex].author?.name
		dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
		if posts[currentPostIndex].commentIsOpen == true, let numberComment = posts[currentPostIndex].comments?.count {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
