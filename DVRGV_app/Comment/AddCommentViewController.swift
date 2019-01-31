//
//  AddCommentViewController.swift
//  DVRGV_app
//
//  Created by clément boussiron on 28/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class AddCommentViewController: UIViewController {
	@IBOutlet weak var commentTextView:UITextView!
	@IBOutlet weak var cancelBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var publishBarButtonItem:UIBarButtonItem!
	var currentPost:Post?
	override func viewDidLoad() {
		super.viewDidLoad()
		}
	

	
	@IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}

	
	@IBAction func publishBarButtonItemTapped(_ sender: UIBarButtonItem) {
		
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
