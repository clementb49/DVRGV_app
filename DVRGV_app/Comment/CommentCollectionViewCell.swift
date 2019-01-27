//
//  CommentCollectionViewCell.swift
//  DVRGV_app
//
//  Created by clément boussiron on 15/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var authorLabel: UILabel!

	@IBOutlet weak var contentTextView: UITextView!
	@IBOutlet weak var dateLabel: UILabel!
	func updateCommentView(comment:Comment) {
		authorLabel.text = comment.authorName
		contentTextView.attributedText = comment.content as? NSAttributedString
		dateLabel.text = DateFormatter.localizedString(from: comment.date_gmt, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
		self.applyAccessibility(comment)
	}
	private func applyAccessibility(_ comment:Comment) {
		self.isAccessibilityElement = true
		var commentString = "le"
		commentString += DateFormatter.localizedString(from: comment.date_gmt, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.none)
		commentString += ". "
		commentString += authorLabel.text!
		commentString += " dit : \n"
		commentString += contentTextView.text!
		self.accessibilityLabel = commentString
		authorLabel.isAccessibilityElement = false
		contentTextView.isAccessibilityElement = false
		dateLabel.isAccessibilityElement = false
	}
}
