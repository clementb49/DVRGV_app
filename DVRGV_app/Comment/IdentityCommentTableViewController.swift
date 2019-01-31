//
//  IdentityCommentTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 27/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit
protocol IdentityCommentTableViewControllerDelegate {
	func didSavedIdentity()
}
class IdentityCommentTableViewController: UITableViewController, UITextFieldDelegate {

	@IBOutlet weak var cancelBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var saveBarButtonItem:UIBarButtonItem!
	@IBOutlet weak var authorNameTextField:UITextField!
	@IBOutlet weak var authorEmailTextField:UITextField!
	var textFieldDelegate:UITextFieldDelegate?
	var identityCommentTableViewControllerDelegate:IdentityCommentTableViewControllerDelegate?
	var isAddComment:Bool?
	@IBOutlet weak var errorAuthorLabel:UILabel!
	@IBOutlet weak var errorEmailLabel:UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		textFieldDelegate=self
	}
	
	
	@IBAction func cancelBarButtonItemTapped(_ sender: UIBarButtonItem) {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	@IBAction func saveBarButtonItemTapped(_ sender: UIBarButtonItem) {
		let authorNameString = authorNameTextField.text!
		let authorEmailString = authorEmailTextField.text!
		if isValideAuthorName(authorNameString) {
			UIView.animate(withDuration: 0.25, animations: {self.errorAuthorLabel.isHidden = true})
			if isValideEmail(authorEmailString) {
				UIView.animate(withDuration: 0.25, animations: {self.errorEmailLabel.isHidden = true})
				let defaults = UserDefaults.standard
				defaults.set(authorNameString, forKey: "authorName")
				defaults.set(authorEmailString, forKey: "authorEmail")
				if isAddComment! {
					self.dismiss(animated: false, completion: {
						self.identityCommentTableViewControllerDelegate?.didSavedIdentity()
					})
				} else {
					self.dismiss(animated: true, completion: nil)
				}
			} else {
				UIView.animate(withDuration: 0.25, animations: {self.errorEmailLabel.isHidden = false})
			}
		} else {
			UIView.animate(withDuration: 0.25, animations: {self.errorEmailLabel.isHidden = false})
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		switch textField {
		case authorNameTextField:
			let isValideAuthorName = self.isValideAuthorName(authorNameTextField.text!)
			if isValideAuthorName {
				authorEmailTextField.becomeFirstResponder()
			}
			UIView.animate(withDuration: 0.25, animations: {self.errorAuthorLabel.isHidden = isValideAuthorName})
		default:
			let isValideEmail = self.isValideEmail(authorEmailTextField.text!)
			if isValideEmail {
				authorEmailTextField.resignFirstResponder()
			}
			UIView.animate(withDuration: 0.25, animations: {self.errorEmailLabel.isHidden = isValideEmail})
		}
		return true
	}
	
	private func isValideEmail(_ test:String) -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: test)
	}
	
	private func isValideAuthorName(_ test:String) -> Bool {
		let authorRegEx = "[A-Za-z0-9()àéèêîïëóûùçñá ]+"
		let authorTest = NSPredicate(format:"SELF MATCHES %@", authorRegEx)
		return authorTest.evaluate(with: test)
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
