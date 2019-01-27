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
		dateLabel.text = DateFormatter.localizedString(from: comment.date_gmt, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
	}
}
