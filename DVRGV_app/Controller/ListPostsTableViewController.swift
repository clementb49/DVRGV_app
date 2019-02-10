//
//  PodcastTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 21/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import CoreData
class ListPostTableViewController: UITableViewController, CategoryPostTableViewControllerDelegate, DetailPostViewControllerDelegate, NSFetchedResultsControllerDelegate {
	var coreDataStack:CoreDataStack!
	var postCategory:Category?
	var categorySelected:Category?
	var activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:40, height:40))
	var isArticleView:Bool?
	var viewIsLoading:Bool?
	private var fetchedResultController:NSFetchedResultsController<Post>?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		updateIsArticleView()
		if viewIsLoading == true {
			setActivityIndicator()
			activityIndicator.startAnimating()
		} else {
			updatePostCategory()
			updateUI()
			updateNavigationItemTitle()
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		if let fetchedResultController = fetchedResultController,
			let sections = fetchedResultController.sections {
			return sections.count
		} else {
			return 0
		}
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let fetchedResultController = fetchedResultController,
			let sections = fetchedResultController.sections else {
				return 0
		}
		return sections[section].numberOfObjects
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
		guard let fetchedResultController = fetchedResultController else {
			return cell
		}
		let post = fetchedResultController.object(at: indexPath)
		cell.textLabel?.text = post.title
		return cell
	}

	
	@IBAction func filterBarButtonItemTapped(_ sender: UIBarButtonItem) {
		var categoryStoryboard:UIStoryboard?
		if isArticleView ?? false {
			categoryStoryboard = UIStoryboard(name: "categoryArticleStoryboard", bundle: nil)
		} else {
		categoryStoryboard = UIStoryboard(name: "CategoryPodcastStoryboard", bundle: nil)
		}
		let vc = categoryStoryboard!.instantiateInitialViewController() as! CategoryPostTableViewController
		vc.modalPresentationStyle = .popover
		vc.postCategory = postCategory
		vc.categorySelected = categorySelected
		guard let childs = postCategory?.childs else {
			return
		}
		var categories =  Array(childs)
		categories.insert(postCategory!, at: 0)
		vc.availableCategories = categories
		vc.categoryDelegate = self
		present(vc, animated: true, completion: nil)
	}
	
	func updateUI() {
		if viewIsLoading == false {
			self.activityIndicator.stopAnimating()
		}
		updateFetchedResultController()
		guard let fetchedResultController = fetchedResultController else {
			return
		}
		do {
			try fetchedResultController.performFetch()
		} catch {
			print("\(error), \(error.localizedDescription)")
		}
	}
	
	func didSelect(category: Category) {
		self.categorySelected = category
		updateUI()
		updateNavigationItemTitle()
		tableView.reloadData()
	}
	
	func setActivityIndicator() {
		activityIndicator.style = .gray
		activityIndicator.center = self.view.center
		self.view.addSubview(activityIndicator)
	}
	
	func updatePostCategory() {
		var predicate:NSPredicate?
		if isArticleView ?? false {
			predicate = NSPredicate(format: "%K == %@", #keyPath(Category.name), "Articles")
		} else {
			predicate = NSPredicate(format: "%K == %@", #keyPath(Category.name), "Podcast")
		}
		self.postCategory = Category.findCategory(predicate: predicate!, context: coreDataStack.mainContext)
		self.categorySelected = postCategory
	}
	
	func updateNavigationItemTitle() {
		if let navController = self.navigationController {
			navController.navigationBar.topItem?.title = categorySelected?.name
		}
	}
	
	func updateIsArticleView() {
		if self.restorationIdentifier == "ListArticleStoryboard" {
			isArticleView = true
		} else {
			isArticleView = false
		}
	}
	
	func updateFetchedResultController() {
		let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date_gmt", ascending: false)]
		fetchRequest.predicate = NSPredicate(format: "%@ IN %K", categorySelected!, #keyPath(Post.categories))
		let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
		fetchedResultController.delegate = self
		self.fetchedResultController = fetchedResultController
	}
	func previewPost(_ currentIndexPath:IndexPath) -> Post? {
		let newIndexPath = IndexPath(item: currentIndexPath.row-1, section: currentIndexPath.section)
		if let fetchedResultController = fetchedResultController {
			return fetchedResultController.object(at: newIndexPath)
		} else {
			return nil
		}
	}
	func nextPost(_ currentIndexPath: IndexPath) -> Post? {
		let newIndexPath = IndexPath(item: currentIndexPath.row+1, section: currentIndexPath.section)
		if let fetchedResultController = fetchedResultController {
			return fetchedResultController.object(at: newIndexPath)
		} else {
			return nil
		}
	}
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PostTableViewCellToDetailPostViewController" {
			guard let destinationViewController = segue.destination as? DetailPostViewController,
			let postCell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: postCell),
			let fetchedResultController = fetchedResultController else {
				return
			}
			destinationViewController.currentPostIndexPath = indexPath
			destinationViewController.currentPost = fetchedResultController.object(at: indexPath)
			destinationViewController.detailPostViewControllerDelegate = self
			destinationViewController.postCount = fetchedResultController.sections![indexPath.section].numberOfObjects
			destinationViewController.coreDataStack = self.coreDataStack
		}
	}
}
