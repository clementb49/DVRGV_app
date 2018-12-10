//
//  PodcastTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 21/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import CoreData
class ListPostTableViewController: UITableViewController, CategoryPostTableViewControllerDelegate {
	var coreDataStack:CoreDataStack!
	var postCategory:Category?
	var categorySelected:Category?
	var posts:[Post]?
	var activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:40, height:40))
	var isArticleView:Bool?
	var viewIsLoading:Bool?
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
		return 1
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let posts = posts else {
			return 0
		}
		return posts.count
	}

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath)
		guard let post = posts?[indexPath.row] else {
			return cell
		}
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
		guard let categorySelected = categorySelected,
			let possts = categorySelected.posts else {
				return
		}
		self.posts = Array(possts)
		let postsSorted = posts?.sorted(by: {$0.date_gmt! > $1.date_gmt!})
		self.posts = postsSorted
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
		let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
		if isArticleView ?? false {
			fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Category.name), "Articles")
		} else {
			fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Category.name), "Podcast")
		}
		fetchRequest.resultType = .managedObjectResultType
		do {
			let categories = try coreDataStack.mainContext.fetch(fetchRequest)
			self.postCategory = categories.first
			self.categorySelected = postCategory
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PodcastTableViewCellToDetailPodcastTableViewController" {
			let destinationViewController = segue.destination as! DetailPodcastViewController
			guard let podcastCell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: podcastCell),
			let post = posts?[indexPath.row] else {
				return
			}
			destinationViewController.post = post
			destinationViewController.podcast = post.podcast
			destinationViewController.coreDataStack = coreDataStack
		}
	}
}
