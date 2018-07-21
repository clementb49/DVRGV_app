//
//  PodcastTableViewCell.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 21/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {
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

}
