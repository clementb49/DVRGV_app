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

import MediaPlayer
class DetailPodcastViewController: UIViewController {
	var posts:[Post]?
	var currentPostIndex:Int?
	var podcast:Podcast?
	var coreDataStack:CoreDataStack!
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var categoryLabel:UILabel!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var authorLabel:UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var readButton:UIButton!
	var podcastImageData:Data?
	override func viewDidLoad() {
		super.viewDidLoad()
		updateUI()
	}
	
	func updateUI() {
		guard let posts:[Post] = self.posts,
			let currentPostIndex = currentPostIndex,
			let podcast = posts[currentPostIndex].podcast,
			let categories = posts[currentPostIndex].categories,
			let date = posts[currentPostIndex].date_gmt,
			let content = posts[currentPostIndex].content else {
			readButton.isEnabled = false
			readButton.isHidden = true
			return
		}
		self.podcast = podcast
		webView.loadHTMLString(content, baseURL: posts[currentPostIndex].link)
		let categoriesArray = Array(categories)
		categoryLabel.text = categoriesArray.last?.name
		titleLabel.text = posts[currentPostIndex].title
		authorLabel.text = posts[currentPostIndex].author?.name
		dateLabel.text = DateFormatter.localizedString(from: date, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
	}
	
	func setupNowPlaying() {
		var nowPlayingInfo = [String:Any]()
		if let posts = posts,
			let currentPostIndex = currentPostIndex,
			let imageData = podcastImageData,
			let image = UIImage(data: imageData) {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {size in return image})
			nowPlayingInfo[MPMediaItemPropertyTitle] = posts[currentPostIndex].title!
			nowPlayingInfo[MPMediaItemPropertyArtist] = posts[currentPostIndex].author!.name!
		}
		MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
	}
	
	func setupRemoteControl(player: AVPlayer) {
		UIApplication.shared.beginReceivingRemoteControlEvents()
		let commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.previousTrackCommand.isEnabled = false
		commandCenter.nextTrackCommand.isEnabled = false
		commandCenter.pauseCommand.addTarget(handler: {event in
			if player.rate == 1.0 {
				player.pause()
				print("pause")
				return .success
			} else {
				return .commandFailed
			}
		})
		commandCenter.playCommand.addTarget(handler: {event in
			if player.rate == 0.0 {
				player.play()
				print("lecture")
				return .success
			} else {
				return .commandFailed
			}
		})
	}
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DetailPodcastViewControllerToPlayerNavigationController" {
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
			setupNowPlaying()
			setupRemoteControl(player: player)
			destinationViewController.player = player
		}
	}
}
