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
	private var audioSession:AVAudioSession
	init(player:AVPlayer) {
		self.player = player
		self.commandCenter = MPRemoteCommandCenter.shared()
		self.audioSession = AVAudioSession.sharedInstance()
		commandCenter.nextTrackCommand.isEnabled = false
		commandCenter.previousTrackCommand.isEnabled = false
		commandCenter.skipBackwardCommand.isEnabled = true
		commandCenter.skipForwardCommand.isEnabled = true

		setupPlayRemoteControl()
		setupPauseRemoteControl()
	}
	func setupPlayRemoteControl() {
		self.commandCenter.playCommand.addTarget { event in
			if self.player.rate == 0.0 {
				do {
					try self.audioSession.setActive(true)
					self.player.play()
					return .success
				} catch let error as NSError {
					print("failed to activate audio session \(error.userInfo)")
					return .commandFailed
				}
			}
			return .commandFailed
		}
	}
	func setupPauseRemoteControl() {
		self.commandCenter.pauseCommand.addTarget { event in
			if self.player.rate >= 1.0 {
				do {
					try self.audioSession.setActive(false)
					self.player.pause()
					print("succès")
					return .success
				} catch let error as NSError {
					print("failed to desactivate audiosession \(error.localizedDescription)")
					return .commandFailed
				}
			}
			return .commandFailed
		}
	}

}

