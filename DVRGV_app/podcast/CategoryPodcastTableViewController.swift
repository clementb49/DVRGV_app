//
//  CategoryPodcastTableViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 06/08/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import CoreData
protocol CategoryPodcastTableViewControllerDelegate {
	func didSelect(category:Category)
}

class CategoryPodcastTableViewController: UITableViewController {
	var podcastCategory:Category?
	var categorySelected:Category?
	var availableCategories:[Category]?
	var categoryDelegate:CategoryPodcastTableViewControllerDelegate?
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	func dismiss() {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Table view data source

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let availableCategories = availableCategories else {
			return 0
		}
		return availableCategories.count
	}


	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "categoryPodcastCell", for: indexPath)
		guard let category = availableCategories?[indexPath.row] else {
			return cell
		}
		cell.textLabel?.text = category.name
		if category == categorySelected {
			cell.accessoryType = .checkmark
		}
		return cell
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let categorySelected = availableCategories?[indexPath.row] else {
			return
		}
		categoryDelegate?.didSelect(category: categorySelected)
		self.dismiss()
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
