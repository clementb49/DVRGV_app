//
//  PostTableViewCell.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 21/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
// conexion between label and code
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	func update(post: Post) {
		guard let title = post.title, let author = post.author?.name, let date = post.date_gmt else {
			return
		}
		titleLabel.text = title
		authorLabel.text = "réaliser par \(author)"
		dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
	}
}
