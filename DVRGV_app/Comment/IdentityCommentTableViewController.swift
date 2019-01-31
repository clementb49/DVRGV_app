//
//  IdentityCommentTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 27/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

class IdentityCommentTableViewController: UITableViewController, UITextFieldDelegate {

	@IBOutlet weak var cancelBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var saveBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var authorNameTextField:UITextField!
	@IBOutlet weak var authorEmailTextField:UITextField!
	var delegate:UITextFieldDelegate?
	var currentPost:Post?
	override func viewDidLoad() {
		super.viewDidLoad()
		delegate=self
	}
	
	
	@IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func saveBarButtonItemTapped(_ sender: UIBarButtonItem) {
		let defaults = UserDefaults.standard
		defaults.set(authorNameTextField.text!, forKey: "authorName")
		defaults.set(authorEmailTextField.text!, forKey: "authorEmail")
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case authorNameTextField:
			authorEmailTextField.becomeFirstResponder()
		default:
			authorEmailTextField.resignFirstResponder()
		}
		return true
	}
	
	private func isValideEmail(_ test:String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: test)
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
