//
//  GameScene.swift
//  Puzzle Game
//
//  Created by Sebastian Waloszek on 11/05/17.
//  Copyright © 2017 SW. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
    var border = SKSpriteNode()
    var piecesCount : Int = 0
    
    var imageNodes = [SKSpriteNode]()

    var guidePhoto = SKSpriteNode()
    
    let image = UIImage(named: "forest")!
    
    var imagesArray = [UIImage]()
    
    var selectedNode = SKSpriteNode()
    
    var selectedNodeStartPosition = CGPoint()
    
    var imageTiles = ([SKSpriteNode](), [CGPoint]())

    private let kNodeName = "movable"
    
    private var isFirstClick = true
    
    private let pieceSize = CGSize(width: 190, height: 175)
    
    private var doubleTap = 0
    
    var scoreLabel = SKLabelNode()
    
    var instructionsLabel = SKLabelNode()
    
    var score = 0
    
    var player = AVAudioPlayer()

    override func didMove(to view: SKView) {
    
        getImagePiecesArray()
        startNewPuzzleGameLevel()
        setPositions()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFirstClick == true {
            randomizeThePieces()
            isFirstClick = false
            guidePhoto.alpha = 0.3
            restartButton()
            addScoreLabel()
            self.removeChildren(in: [instructionsLabel])
        }
        else{
            
            let touch = touches.first
            let positionInScene = touch?.location(in: self)

            selectNodeForTouch(touchLocation: positionInScene!)
            
            if touch?.tapCount == 2 && selectedNode.name != "correct"{
                
                let rotateAction = SKAction.rotate(byAngle: CGFloat(Double.pi) / 2, duration: 0.25)
                
                selectedNode.run(rotateAction)
                
            }
            
            selectedNodeStartPosition = selectedNode.position
            
            
            
        }
    }
    
    func setPositions(){
        
         for i in 0 ..< 16 {
            
            if i < 4{
                imageTiles.1.append(CGPoint(x: self.frame.minX + pieceSize.width/2 + CGFloat(i)*pieceSize.width, y: pieceSize.height/2*3))
            }
            else if(i < 8){
                imageTiles.1.append(CGPoint(x: self.frame.minX + pieceSize.width/2 + CGFloat(i-4)*pieceSize.width, y: pieceSize.height/2))
            }
                
            else if(i < 12){
                imageTiles.1.append(CGPoint(x: self.frame.minX + pieceSize.width/2 + CGFloat(i-8)*pieceSize.width, y: -pieceSize.height/2))
            }
                
            else{
                imageTiles.1.append(CGPoint(x: self.frame.minX + pieceSize.width/2 + CGFloat(i-12)*pieceSize.width, y: -pieceSize.height/2*3))
            }
            
        }
        
    }
    
    func playSound(soundName: String){
        
        let url = Bundle.main.url(forResource: soundName, withExtension: "mp3")!
        
        do{
            try player = AVAudioPlayer(contentsOf: url)
        }
        catch{
            
        }
            player.prepareToPlay()
            player.play()
        
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let snapDistance = CGFloat(50)
        if selectedNode.name != "correct"{
        for i in 0 ..< 16 {
            if selectedNode == imageTiles.0[i] {
                
                if Int(selectedNode.zRotation) == 6 {
                    selectedNode.zRotation = 0
                }
                
                if(Swift.abs(selectedNode.position.x - imageTiles.1[i].x) < snapDistance && Swift.abs(selectedNode.position.y - imageTiles.1[i].y) < snapDistance
                    && ( Int(selectedNode.zRotation) == 0 || Int(selectedNode.zRotation) == 5) ){
                    selectedNode.position.x = imageTiles.1[i].x
                    selectedNode.position.y = imageTiles.1[i].y
                    selectedNode.name = "correct"
                    score += 1
                    scoreLabel.text = "Correct pieces: " + String(score) + "/16"
                    selectedNode.zPosition = 1
                    
                    playSound(soundName: "sonic_ring")
                    
                    if score == 16 {
                        scoreLabel.fontColor = .green
                        playSound(soundName: "applause")
                    }
                }
                else if(selectedNode.position.y < (self.frame.midY + 698/2+5) && selectedNode.position.y > self.frame.midY - 698/2+5){
                    
                    let moveAction = SKAction.move(to: selectedNodeStartPosition, duration: 0.25)
                    
                    selectedNode.run(moveAction)
                    playSound(soundName: "wrong_sound")
                }
            }
        }
    }
        
    }
    
    func getImagePiecesArray() {
        let tilesInLine = 4
        
        piecesCount = tilesInLine * tilesInLine
  
        imagesArray = sliceImageToPieces(CGSize(width: 760, height: 700), pieceSize: pieceSize)
      
    }

    func startNewPuzzleGameLevel(){
        
        addInstructionsLabel()

        guidePhoto = SKSpriteNode(imageNamed: "forest")
        
        guidePhoto.size = CGSize(width: 760, height: 700)
        
        guidePhoto.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        
        guidePhoto.name = "guidePhoto"
        
        guidePhoto.zPosition = -1
        
        self.addChild(guidePhoto)
    
        
    }
    
    func randomizeThePieces(){
        
        let rotationAmountArray = [0.5, 1.0, 1.5, 2.0]
        
        for i in 0...15 {
         
        let texture = SKTexture(image: imagesArray[i])
        
        let cuttedPhoto = SKSpriteNode(texture: texture)
            
        let distance = 95
        
        if i < 8 {
            
                 cuttedPhoto.position = CGPoint(x: self.frame.minX + CGFloat(i * distance), y: self.frame.maxY - 160)
        }
        else{
                cuttedPhoto.position = CGPoint(x: self.frame.minX + CGFloat(i%8 * distance), y: self.frame.minY + 160)
            
        }
             let randomRotationIndex = Int(arc4random_uniform(UInt32(rotationAmountArray.count)))
             cuttedPhoto.zRotation = CGFloat(Double.pi) * CGFloat(rotationAmountArray[randomRotationIndex])
             cuttedPhoto.name = kNodeName
             self.addChild(cuttedPhoto)
            
             imageTiles.0.append(cuttedPhoto)
        
        }
        
    }
    
    func addScoreLabel()  {
        
        scoreLabel.fontSize = 48
        scoreLabel.text = "Correct pieces: " + String(score) + "/16"
        
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 698/2+5)
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 4
        
        self.addChild(scoreLabel)
        
    }
    
    func addInstructionsLabel()  {
        
        instructionsLabel.fontSize = 48
        instructionsLabel.text = String(score)
        
        instructionsLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 698/2+20)
        instructionsLabel.name = "instructionsLabel"
        instructionsLabel.zPosition = 4
        instructionsLabel.text = "Click on the image to start the puzzle!"
        
        self.addChild(instructionsLabel)
        
    }
    
    func restartButton(){
        
        let button = SKButton(color: .red, size: .zero)
        
        button.animatable = true
        
        button.size = CGSize(width: 100, height: 50)
        button.anchorPoint = CGPoint(x: 0, y: 0)
        button.position = CGPoint(x: frame.midX-50, y: frame.midY-698/2-button.size.height)
        button.zPosition = 4
        
        button.setTitle(string: "Restart")
        
        button.addTarget(target: self, selector: #selector(tapped), event: SKButtonEvent.TouchUpInside)
        
        addChild(button)
    }
    
    func tapped(){
        score = 0
        scoreLabel.fontColor = .white
        isFirstClick = true
        self.removeAllChildren()
        imageTiles = ([SKSpriteNode](), [CGPoint]())
        
        startNewPuzzleGameLevel()
        setPositions()
        
    }
    
    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        
        if selectedNode.name! == kNodeName {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)

            selectedNode.zPosition = 2
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let positionInScene = touch?.location(in: self)
        
        let previousPosition = touch?.previousLocation(in: self)
        let translation = CGPoint(x: (positionInScene?.x)! - (previousPosition?.x)!, y: (positionInScene?.y)! - (previousPosition?.y)!)
        
        panForTranslation(translation: translation)
        
    }
    
    func degToRad(degree: Double) -> CGFloat {
        return CGFloat(Double(degree) / 180.0 * Double.pi)
    }
    
    func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                
                selectedNode = touchedNode as! SKSpriteNode
            }
        }
    }
    
    func sliceImageToPieces(_ imageSize : CGSize, pieceSize : CGSize) -> [UIImage]{
        
        let whole = resizeImage(imageSize, image: image)
        
        var imagesArray = [UIImage]()
        
        let imagesCountInLine = Int(imageSize.width / pieceSize.width)
        let tilesCount = Int(imagesCountInLine * imagesCountInLine)
        
        var line = 0
        var row = 0
        
        for _ in 0 ..< tilesCount {
            
            let cgImg = whole.cgImage!.cropping(to: CGRect(x: CGFloat(row) * pieceSize.width,y: CGFloat(line) * pieceSize.height, width: pieceSize.width, height: pieceSize.height));
            
            let img = UIImage(cgImage: cgImg!)
            imagesArray.append(img)
            
            if row == imagesCountInLine - 1{
                line += 1
                row = 0
            }
            else{
                row += 1
            }
        }
        
        return imagesArray
    }
    
    
    func resizeImage(_ size: CGSize, image : UIImage) -> UIImage {
        
        UIGraphicsBeginImageContext(size);
        
        let context = UIGraphicsGetCurrentContext();
        context!.translateBy(x: 0.0, y: size.height);
        context!.scaleBy(x: 1.0, y: -1.0);
        
        context!.draw(image.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return scaledImage!
        
    }

        
}
