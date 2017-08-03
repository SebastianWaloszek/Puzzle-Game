//
//  SoundPlayer.swift
//  Puzzle Game
//
//  Created by Sebastian Waloszek on 03/08/2017.
//  Copyright © 2017 SW. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer{
    
    private static var player = AVAudioPlayer()
    
    static func playSound(soundName: String){
        
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")!
        
        do{
            try player = AVAudioPlayer(contentsOf: url)
        }
        catch let error{
            print(error.localizedDescription)
        }
        player.prepareToPlay()
        player.play()
        
    }
    
}
