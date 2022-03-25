//
//  File.swift
//  
//
//  Created by Luigi Da Ros on 05/11/21.
//

import Foundation
import UIKit
import AVFAudio

enum MeetingEffect: String, CaseIterable
{
	case startCall = "startCallEffect"
	case endCall = "endCallEffect"
	
	var effectUrl: URL? {
		get{
			return Bundle.module.url(forResource: self.rawValue, withExtension: "mp3")
		}
	}
}

class MeetingEffectPlayer: NSObject {
	var players: [MeetingEffect: AVAudioPlayer] = [MeetingEffect: AVAudioPlayer]()
	
	override init() {
		super.init()
		
		MeetingEffect.allCases.forEach { effect in
			if let url = effect.effectUrl
			{
				do
				{
					let player = try AVAudioPlayer(contentsOf: url)
					player.prepareToPlay()
					
					players[effect] = player
				}
				catch
				{
					VeganLogger.err("Error loading sound effect \(error)")
				}
			}
		}
	}
	
	func playEffect(effect: MeetingEffect)
	{
		if let player = players[effect]
		{
			player.play()
		}
	}
		
}
