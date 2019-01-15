//
//  CommentCollectionViewCell.swift
//  DVRGV_app
//
//  Created by clément boussiron on 15/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var userLabel:UILabel!
	@IBOutlet weak var contentTextView:UITextView!
	@IBOutlet weak var dateLabel:UILabel!
	func updateCommentView(comment:Comment) {
		userLabel.text = comment.authorName
		contentTextView.attributedText = comment.content as NSAttributedString
	}
}
