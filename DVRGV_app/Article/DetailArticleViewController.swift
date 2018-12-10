//
//  DetailArticleViewController.swift
//  DVRGV_app
//
//  Created by clément boussiron on 10/12/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class DetailArticleViewController: UIViewController {
	var posts:[Post]?
	var currentPostIndex:Int?
	var podcast:Podcast?
	
	@IBOutlet weak var categoryLabel: UILabel!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
