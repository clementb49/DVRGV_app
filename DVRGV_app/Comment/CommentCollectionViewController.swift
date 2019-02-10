//
//  CommentCollectionViewController.swift
//  DVRGV_app
//
//  Created by clément boussiron on 15/01/2019.
//  Copyright © 2019 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import CoreData
private let reuseIdentifier = "commentCell"
class CommentCollectionViewController: UICollectionViewController, IdentityCommentTableViewControllerDelegate, NSFetchedResultsControllerDelegate {
	var currentPost:Post!
	var coreDataStack:CoreDataStack!
	private lazy var fetchedResultControler:NSFetchedResultsController<Comment> = {
		let fetchRequest:NSFetchRequest<Comment> = NSFetchRequest(entityName: "Comment")
		fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Comment.post), currentPost)
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_gmt", ascending: true)]
		fetchRequest.resultType = .managedObjectResultType
		let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultController.delegate = self
		return fetchedResultController
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		do {
			try fetchedResultControler.performFetch()
		} catch {
	}
		
		let numberComment = fetchedResultControler.fetchedObjects!.count
		if numberComment == 0 || numberComment == 1 {
			self.navigationItem.title = "\(numberComment) commentaire"
		} else {
			self.navigationItem.title = "\(numberComment) commentaires"
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
		if let sections = fetchedResultControler.sections {
			self.restore()
			return sections.count
		} else {
			self.setEmpty()
			return 0
		}
	}


	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if let sections = fetchedResultControler.sections {
			let numberOfObject =  sections[section].numberOfObjects
			if numberOfObject == 0 {
				setEmpty()
			} else {
				restore()
			}
			return numberOfObject
		} else {
			return 0
		}
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let commentCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCollectionViewCell
		commentCell.updateCommentView(comment: fetchedResultControler.object(at: indexPath))
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
			let identityCommentTableViewController = navController.topViewController as! IdentityCommentTableViewController
			identityCommentTableViewController.identityCommentTableViewControllerDelegate = self
			identityCommentTableViewController.isAddComment = true
			self.present(navController, animated: true, completion: nil)
		} else {
			self.didSavedIdentity()
		}
	}
	
	func didSavedIdentity() {
		let storyboard = UIStoryboard.init(name:"AddCommentStoryboard", bundle: nil)
		let navController = storyboard.instantiateInitialViewController() as! UINavigationController
		let addCommentViewController = navController.topViewController as! AddCommentViewController
		addCommentViewController.currentPost = self.currentPost

		self.present(navController, animated: true, completion: nil)
	}
}
