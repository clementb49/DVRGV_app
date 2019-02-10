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
import SafariServices
import CoreData
protocol DetailPostViewControllerDelegate {
	func previewPost(_ currentIndexPath:IndexPath) -> Post?
	func nextPost(_ currentIndexPath:IndexPath) -> Post?
}
class DetailPostViewController: UIViewController, WKNavigationDelegate {
	var currentPostIndexPath:IndexPath?
	private var currentPostPodcast:Podcast?
	var currentPost:Post?
	@IBOutlet weak var webView: WKWebView!
	@IBOutlet weak var categoryLabel:UILabel!
	@IBOutlet weak var titleLabel:UILabel!
	@IBOutlet weak var authorLabel:UILabel!
	@IBOutlet weak var dateLabel:UILabel!
	@IBOutlet weak var readButton:UIButton?
	var podcastImageData:Data?
	@IBOutlet weak var commentButton: UIBarButtonItem!
	var detailPostViewControllerDelegate:DetailPostViewControllerDelegate?
	var postCount:Int?
	var coreDataStack:CoreDataStack!
	override func viewDidLoad() {
		super.viewDidLoad()
		webView.navigationDelegate = self
		updateUI()
	}
	
	func updateUI() {
		guard let currentPost = self.currentPost,
			let postCategories = currentPost.categories,
			let postDate = currentPost.date_gmt,
			let postContent = currentPost.content,
			let postLink = currentPost.link,
		let postTitle = currentPost.title,
		let postAuthor = currentPost.author else {
			return
		}
		webView.loadHTMLString(postContent, baseURL: URL(string: postLink))
		let categoriesArray = Array(postCategories)
		self.currentPostPodcast = currentPost.podcast
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
	

	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		if navigationAction.navigationType == WKNavigationType.linkActivated {
			if let url = navigationAction.request.url {
				openURL(url:url)
				decisionHandler(WKNavigationActionPolicy.cancel)
			} else {
				decisionHandler(WKNavigationActionPolicy.allow)
			}
		} else {
			decisionHandler(WKNavigationActionPolicy.allow)
		}
	}
	
	private func openURL(url:URL) {
		if let host = url.host, host=="www.dvrgv.org" {
			let predicate = NSPredicate(format: "%K == %@", #keyPath(Post.link), url.absoluteString)
			let post = Post.findPost(predicate: predicate, context: coreDataStack.mainContext)
			if let post = post {
				var storyBoard = UIStoryboard.init()
				if post.podcast != nil {
					storyBoard = UIStoryboard.init(name: "DetailPodcastStoryboard", bundle: nil)
				} else {
					storyBoard = UIStoryboard.init(name: "DetailArticleStoryboard", bundle: nil)
				}
				let viewController = storyBoard.instantiateInitialViewController() as! DetailPostViewController
				viewController.currentPost = post
				viewController.coreDataStack = self.coreDataStack
				viewController.postCount = 1
				self.show(viewController, sender: nil)
			} else {
				let safariViewController = SFSafariViewController.init(url: url)
				self.present(safariViewController, animated: true, completion: nil)
			}
		} else {
			let safariViewController = SFSafariViewController.init(url: url)
			self.present(safariViewController, animated: true, completion: nil)
		}
	}

// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "DetailPostViewControllerToPlayerNavigationController" {
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
		} else if segue.identifier == "DetailPostViewControllerToCommentCollectionViewController" {
			guard let currentPost = self.currentPost,
				let destinationViewController = segue.destination as? CommentCollectionViewController else {
					return
			}
			destinationViewController.currentPost = currentPost
			destinationViewController.coreDataStack = self.coreDataStack
		}
	}
}
