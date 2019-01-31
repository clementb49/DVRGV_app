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
class DetailPostViewController: UIViewController {
	var posts:[Post]?
	var currentPostIndex:Int?
	private var currentPostPodcast:Podcast?
	private var currentPost:Post?
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var categoryLabel:UILabel!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var authorLabel:UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var readButton:UIButton?
	var podcastImageData:Data?
	@IBOutlet weak var commentButton: UIBarButtonItem!
	override func viewDidLoad() {
		super.viewDidLoad()
		updateUI()
	}
	
	func updateUI() {
		updateCurentPost()
		guard let currentPost = self.currentPost,
			let postCategories = currentPost.categories,
			let postDate = currentPost.date_gmt,
			let postContent = currentPost.content,
			let postLink = currentPost.link,
		let postTitle = currentPost.title,
		let postAuthor = currentPost.author else {
			return
		}
		webView.loadHTMLString(postContent, baseURL: postLink)
		let categoriesArray = Array(postCategories)
		categoryLabel.text = categoriesArray.last?.name
		titleLabel.text = postTitle
		authorLabel.text = postAuthor.name
		dateLabel.text = DateFormatter.localizedString(from: postDate, dateStyle: DateFormatter.Style.long, timeStyle: DateFormatter.Style.medium)
		if currentPost.commentIsOpen == true, let numberComment = currentPost.comments?.count {
			commentButton.isEnabled = true
			if numberComment == 0 || numberComment == 1 {
				commentButton.title = "\(numberComment) commentaire"
			} else {
				commentButton.title = "\(numberComment) commentaires"
			}
		} else {
			commentButton.isEnabled = false
		}
	}
	
	func setupNowPlaying() {
		var nowPlayingInfo = [String:Any]()
		if let currentPost = self.currentPost,
			let imageData = podcastImageData,
			let postTitle = currentPost.title,
			let postAuthor = currentPost.author,
			let image = UIImage(data: imageData) {
			nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: {size in return image})
			nowPlayingInfo[MPMediaItemPropertyTitle] = postTitle
			nowPlayingInfo[MPMediaItemPropertyArtist] = postAuthor.name!
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
	
	private func updateCurentPost() {
		guard let posts = self.posts,
		let currentPostIndex = self.currentPostIndex else {
				return
		}
		self.currentPost = posts[currentPostIndex]
		self.currentPostPodcast = self.currentPost?.podcast
	}
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DetailPodcastViewControllerToPlayerNavigationController" {
			let destinationViewController = segue.destination as! AVPlayerViewController
			guard let currentPostPodcast = self.currentPostPodcast,
			let podcastURL = currentPostPodcast.audioURL else {
				return
			}
			let player = AVPlayer(url: podcastURL)
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
		if segue.identifier == "detailPodcastViewControllerToCommentCollectionViewController"  || segue.identifier == "detailArticleViewControllerToCommentCollectionViewController" {
			guard let currentPost = self.currentPost,
				let comments = currentPost.comments,
				let destinationViewController = segue.destination as? CommentCollectionViewController else {
					return
			}
			destinationViewController.currentPost = self.currentPost
			destinationViewController.comments = Array(comments)
		}
	}
}
