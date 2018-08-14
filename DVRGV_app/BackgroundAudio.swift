//
//  BackgroundAudio.swift
//  DVRGV_app
//
//  Created by Clément BOUSSIRON on 13/08/2018.
//  Copyright © 2018 Clément BOUSSIRON. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
class BackgroundAudio {
	private var commandCenter:MPRemoteCommandCenter
	private var player:AVPlayer
	init(player:AVPlayer) {
		self.player = player
		self.commandCenter = MPRemoteCommandCenter.shared()
		commandCenter.nextTrackCommand.isEnabled = false
		commandCenter.previousTrackCommand.isEnabled = false
	}
	func setupPlayRemoteControl() {
		self.commandCenter.playCommand.addTarget { [unowned self] event in
			if self.player.rate == 0.0 {
				self.player.play()
				return .success
			}
			return .commandFailed
		}
	}
	func setupPauseRemoteControl() {
		self.commandCenter.pauseCommand.addTarget {[unowned self] event in
			if self.player.rate >= 1.0 {
				self.player.pause()
				return .success
			}
			return .commandFailed
		}
	}

}
