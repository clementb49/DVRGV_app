//
//  IdentityCommentTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 27/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class IdentityCommentTableViewController: UITableViewController {

	@IBOutlet weak var cancelBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var saveBarButtonItem:UIBarButtonItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	
	@IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
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
