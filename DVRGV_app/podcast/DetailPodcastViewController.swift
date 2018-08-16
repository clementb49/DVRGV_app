//
//  DetailPodcastViewController.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 08/08/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import AVKit
class DetailPodcastViewController: UIViewController {
	var post:Post?
	var podcast:Podcast?
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var categoryLabel:UILabel!
	@IBOutlet weak var TitleLabel:UILabel!
	@IBOutlet weak var authorLabel:UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var readButton:UIButton!
	override func viewDidLoad() {
		super.viewDidLoad()
		guard let post = post,
		let categories = post.categories,
		let date = post.date_gmt,
		let content = post.content,
		let podcast = podcast else {
			readButton.isEnabled = false
			readButton.isHidden = true
			return
		}
		webView.loadHTMLString(content, baseURL: post.link)
		let categoriesArray = Array(categories)
		categoryLabel.text = categoriesArray.last?.name
		TitleLabel.text = post.title
		authorLabel.text = post.author?.name
		dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DetailPodcastViewControllerToAVPlayerViewController" {
			let destinationViewController = segue.destination as! AVPlayerViewController
			guard let podcast = podcast else {
				return
			}
			let player = AVPlayer(url: podcast.audioURL!)
			let audioSession = AVAudioSession.sharedInstance()
			do {
				try audioSession.setActive(true)
			} catch let error as NSError {
				print("failed to activate the audio session: \(error.localizedDescription)")
			}
			player.automaticallyWaitsToMinimizeStalling = true
			player.allowsExternalPlayback = true
			player.playImmediately(atRate: 1.0)
			destinationViewController.player = player
		}
	}
}
