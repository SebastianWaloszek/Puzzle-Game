//
//  SKButton.swift
//  puzzleGame
//
//  Created by Arturs Derkintis on 8/12/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import SpriteKit

enum SKButtonState {
    case Normal
    case Highlighted
}
enum SKButtonEvent{
    case TouchDown
    case TouchUpInside
}
class SKButton: SKSpriteNode {
    var targetUp : AnyObject?
    var selectorUp : Selector?
    var normalStateTexture : SKTexture?
    var hLightStateTexture : SKTexture?
    var animatable : Bool = false
    var eventUp : SKButtonEvent?
    var soundFile : String?
    var textLabel : SKLabelNode?
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
        self.isUserInteractionEnabled = true
        textLabel = SKLabelNode()
        textLabel?.position = CGPoint(x: 50, y: 15)
        textLabel?.fontSize = 30
        addChild(textLabel!)
    }
    func setTitle(string : String){
        textLabel?.text = string
    }
    func addTarget(target : AnyObject?, selector: Selector, event : SKButtonEvent){
        eventUp = event
        targetUp = target
        selectorUp = selector
    }
    
    func setImageForState(image : UIImage, state : SKButtonState){
        if state == .Normal{
            normalStateTexture = SKTexture(image: image)
            texture = normalStateTexture
        }else if state == .Highlighted{
            hLightStateTexture = SKTexture(image: image)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = hLightStateTexture
        if animatable{
            let action = SKAction.scale(to: 0.95, duration: 0.1)
            run(action)
        }
        if let sound = soundFile{
            let soundAction = SKAction.playSoundFileNamed(sound, waitForCompletion: false)
            run(soundAction)
        }
        if eventUp == .TouchDown{
            Timer.scheduledTimer(timeInterval: 0.01, target: targetUp!, selector: selectorUp!, userInfo: nil, repeats: false)
            
        }

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        texture = normalStateTexture
        
        if animatable{
            let action = SKAction.scale(to: 1.0, duration: 0.1)
            run(action)
        }
        if eventUp == .TouchUpInside{
            Timer.scheduledTimer(timeInterval: 0.01, target: targetUp!, selector: selectorUp!, userInfo: nil, repeats: false)
            
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
