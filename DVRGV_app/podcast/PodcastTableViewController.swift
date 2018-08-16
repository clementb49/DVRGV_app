//
//  PodcastTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 21/07/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import CoreData
class PodcastTableViewController: UITableViewController, CategoryPodcastTableViewControllerDelegate {
	var coreDataStack:CoreDataStack!
	var podcastCategory:Category?
	var categorySelected:Category?
	var posts:[Post]?
	var activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:40, height:40))
	override func viewDidLoad() {
		super.viewDidLoad()
		if activityIndicator.isAnimating == true {
			setActivityIndicator()
		} else {
			updatePodcastCategory()
			updateUI()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "podcastCell", for: indexPath) as! PodcastTableViewCell
		guard let post = posts?[indexPath.row] else {
			return cell
		}
		cell.update(post: post)
		return cell
	}

	@IBAction func filterBarButtonItemTapped(_ sender: UIBarButtonItem) {
		let storyboard:UIStoryboard = UIStoryboard(name: "podcastStoryboard", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: "categoryPodcastTableViewController") as! CategoryPodcastTableViewController
		vc.modalPresentationStyle = .popover
		vc.podcastCategory = podcastCategory
		vc.categorySelected = categorySelected
		guard let childs = podcastCategory?.childs else {
			return
		}
		var categories =  Array(childs)
		categories.insert(podcastCategory!, at: 0)
		vc.availableCategories = categories
		vc.categoryDelegate = self
		present(vc, animated: true, completion: nil)
	}
	
	func updateUI() {
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
		tableView.reloadData()
	}
	
	func setActivityIndicator() {
		activityIndicator.style = .gray
		activityIndicator.center = self.view.center
		self.view.addSubview(activityIndicator)
	}
	
	func updatePodcastCategory() {
		let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
		fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Category.name), "Podcast")
		fetchRequest.resultType = .managedObjectResultType
		do {
			let categories = try coreDataStack.mainContext.fetch(fetchRequest)
			self.podcastCategory = categories.first
			self.categorySelected = podcastCategory
		} catch let error as NSError {
			print("error, \(error), \(error.userInfo)")
		}
	}
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "PodcastTableViewCellToDetailPodcastTableViewController" {
			let destinationViewController = segue.destination as! DetailPodcastViewController
			guard let podcastCell = sender as? PodcastTableViewCell,
			let indexPath = tableView.indexPath(for: podcastCell),
			let post = posts?[indexPath.row] else {
				return
			}
			destinationViewController.post = post
			destinationViewController.podcast = post.podcast
		}
	}
}
