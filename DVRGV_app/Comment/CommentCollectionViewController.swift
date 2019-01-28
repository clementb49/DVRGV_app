//
//  CommentCollectionViewController.swift
//  DVRGV_app
//
//  Created by clément boussiron on 15/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit

private let reuseIdentifier = "commentCell"

class CommentCollectionViewController: UICollectionViewController {

	var comments:[Comment]?

	override func viewDidLoad() {
		super.viewDidLoad()
		if let comments = self.comments {
			let numberComment = comments.count
			self.comments = comments.sorted(by: {$0.date_gmt < $1.date_gmt})
			if numberComment == 0 || numberComment == 1 {
				self.navigationItem.title = "\(numberComment) commentaire"
			} else {
				self.navigationItem.title = "\(numberComment) commentaires"
			}
		}
		self.collectionView!.isAccessibilityElement = false
		self.collectionView.shouldGroupAccessibilityChildren = true
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
		if self.comments != nil && comments?.count != 0 {
			self.restore()
			return 1
		} else {
			self.setEmpty()
			return 0
		}
	}


	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let comments = comments {
			return comments.count
		} else {
			return 0
		}
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let commentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCollectionViewCell
		let comment = comments![indexPath.row]
		commentCell.updateCommentView(comment: comment)
		return commentCell
	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

	private func setEmpty() {

		let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.collectionView.bounds.width, height: self.collectionView.bounds.height))
		messageLabel.text = "aucun commentaire"
		messageLabel.textColor = UIColor.black
		messageLabel.textAlignment = NSTextAlignment.center
		messageLabel.sizeToFit()
		self.collectionView.backgroundView = messageLabel
	}
	private func restore() {
		self.collectionView.backgroundView = nil
	}
	
	
	@IBAction func addCommentBarButtonItemTapped(_ sender: UIBarButtonItem) {
		let defaults = UserDefaults.standard
		if defaults.string(forKey: "authorName") == nil && defaults.string(forKey: "authorEmail") == nil {
			let storyboard = UIStoryboard.init(name: "identityCommentStoryboard", bundle: nil)
			let navController = storyboard.instantiateInitialViewController() as! UINavigationController
			self.present(navController, animated: true, completion: nil)
		} else {
			let storyboard = UIStoryboard.init(name:"AddCommentStoryboard", bundle: nil)
			let navController = storyboard.instantiateInitialViewController() as! UINavigationController
			self.present(navController, animated: true, completion: nil)
		}
	}
}
