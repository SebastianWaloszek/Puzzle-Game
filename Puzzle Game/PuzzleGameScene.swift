//
//  GameScene.swift
//  Puzzle Game
//
//  Created by Sebastian Waloszek on 11/05/17.
//  Copyright © 2017 SW. All rights reserved.
//

import SpriteKit
import GameplayKit


class PuzzleGameScene: SKScene {
    
    fileprivate struct Constants{
        
        static let succesSound = "success_sound"
        static let wrongSound = "wrong_sound"
        static let wonGameSound = "applause_sound"
        
        static let imageForPuzzle = "forest"
        
        static let staticNodeName = "staticNodeName"
        static let movableNodeName = "movable"
        
        static let fontSize:CGFloat = 48
        
        static let puzzlePieceSnapDistance = CGFloat(50)
        
        static let puzzleImageSize = CGSize(width: 760, height: 700)
        static let puzzlePieceSize = CGSize(width: 190, height: 175)
        
        static let labelOffset:CGFloat = 10
        
        static let numberOfPuzzlePieces = 16
        
        static let animationDuration = 0.25
        
    }

    private var selectedNode = SKSpriteNode()
    private var selectedNodeStartPosition = CGPoint()
    fileprivate var puzzlePieces = (piece: [SKSpriteNode](), correctPosition: [CGPoint]())
    
    private enum GameState{
        case start
        case playing
        case won
    }
    
    
    private var gameState = GameState.start{
        didSet{
            switch self.gameState {
            case .start:
                instructionsLabel = SKLabelNode()
                guidePhoto = SKSpriteNode()
            case .playing:
                scoreLabel = SKLabelNode()
                guidePhoto.alpha = 0.3
                setUpRestartButton()
            case .won:
                scoreLabel.fontColor = .green
                SoundPlayer.playSound(soundName: Constants.wonGameSound)
            }
        }
    }
    

    private var guidePhoto = SKSpriteNode(){
        didSet{
            
            guidePhoto = SKSpriteNode(imageNamed: Constants.imageForPuzzle)
            guidePhoto.size = Constants.puzzleImageSize
            guidePhoto.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            guidePhoto.name = Constants.staticNodeName
            guidePhoto.zPosition = -1
            
            self.addChild(guidePhoto)
        }
    }
    
    private var scoreLabel = SKLabelNode() {
        didSet{
            
            scoreLabel.fontSize = Constants.fontSize
            scoreLabel.text = setScoreString(score: score)
            
            if score == 0 {
                scoreLabel.fontColor = .white
            }
            
            scoreLabel.position = CGPoint(x: self.frame.midX,
                                          y: self.frame.midY + Constants.puzzleImageSize.height/2 + Constants.labelOffset
            )
            scoreLabel.zPosition = 4
            
            self.addChild(scoreLabel)
        }
    }
    
    private var instructionsLabel = SKLabelNode(){
        didSet{
            instructionsLabel.fontSize = Constants.fontSize
            
            instructionsLabel.position = CGPoint(x: self.frame.midX,
                                                 y: self.frame.midY + Constants.puzzleImageSize.height/2 + Constants.labelOffset
            )
            instructionsLabel.zPosition = 4
            instructionsLabel.text = "Click on the image to start the puzzle!"
            
            self.addChild(instructionsLabel)
        }
    }
    
    private var score = 0{
        didSet{
            scoreLabel.text = setScoreString(score: score)
        }
        
        willSet{
            if (newValue > score && newValue > 0){
                SoundPlayer.playSound(soundName: Constants.succesSound)
            }
        }
    }
    
    private func setScoreString(score: Int) -> String{
        return "Correct pieces: " + String(score) + "/\(Constants.numberOfPuzzlePieces)"
    }
    
    private func setUpRestartButton(){
        
        let button = SKButton(color: .red, size: .zero)
        
        button.animatable = true
        
        button.size = CGSize(width: 100, height: 50)
        button.anchorPoint = CGPoint(x: 0, y: 0)
        button.position = CGPoint(x: frame.midX - button.size.height,
                                  y: frame.midY - Constants.puzzleImageSize.height/2 - button.size.height
        )
        button.zPosition = 4
        
        button.setTitle(string: "Restart")
        
        button.addTarget(target: self, selector: #selector(restartGame), event: SKButtonEvent.TouchUpInside)
        
        addChild(button)
    }
    
    @objc private func restartGame(){
        
        score = 0
        self.removeAllChildren()
        
        gameState = GameState.start
        puzzlePieces = (piece: [SKSpriteNode](), correctPosition: [CGPoint]())
        createPuzzlePieces()
        
    }
    
    override func didMove(to view: SKView) {
        
        gameState = .start
        createPuzzlePieces()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameState == GameState.start {
            self.removeChildren(in: [instructionsLabel])
            randomize(puzzlePieces: puzzlePieces.0, inFrame: frame)
            gameState = GameState.playing
            
        }else {
            
            let touch = touches.first
            let positionInScene = touch?.location(in: self)
            
            selectNodeForTouch(touchLocation: positionInScene!)
            
            if touch?.tapCount == 2 && selectedNode.name != Constants.staticNodeName{
                
                let rotateAction = SKAction.rotate(byAngle: CGFloat(Double.pi) / 2, duration: Constants.animationDuration)
                
                selectedNode.run(rotateAction)
                
            }
            
            selectedNodeStartPosition = selectedNode.position
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let name = selectedNode.name,name != Constants.staticNodeName{
            
            for i in 0 ..< Constants.numberOfPuzzlePieces {
                if selectedNode == puzzlePieces.0[i] {
                    
                    if Int(selectedNode.zRotation) == 6 {
                        selectedNode.zRotation = 0
                    }
                    
                    let correctPosition = puzzlePieces.1[i]
                    
                    if isPositionCorrect(forPuzzlePiece: selectedNode, correctPosition: correctPosition){
                        
                        selectedNode.position = correctPosition
                        selectedNode.name = Constants.staticNodeName
                        selectedNode.zPosition = 1
                        
                        score += 1
                        
                        if score == Constants.numberOfPuzzlePieces {
                            gameState = GameState.won
                        }
                    }
                    else if(selectedNode.position.y < (self.frame.midY + Constants.puzzleImageSize.height/2) &&
                        selectedNode.position.y > self.frame.midY - Constants.puzzleImageSize.height/2){
                        
                        let moveAction = SKAction.move(to: selectedNodeStartPosition, duration: Constants.animationDuration)
                        
                        selectedNode.run(moveAction)
                        SoundPlayer.playSound(soundName: Constants.wrongSound)
                        
                    }
                }
            }
        }
        
    }
    
    func isPositionCorrect(forPuzzlePiece puzzlePiece:SKSpriteNode, correctPosition: CGPoint) -> Bool{
        
        return Swift.abs(selectedNode.position.x - correctPosition.x) < Constants.puzzlePieceSnapDistance &&
            Swift.abs(selectedNode.position.y - correctPosition.y) < Constants.puzzlePieceSnapDistance &&
            (Int(selectedNode.zRotation) == 0 || Int(selectedNode.zRotation) == 5)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let positionInScene = touch?.location(in: self)
        
        let previousPosition = touch?.previousLocation(in: self)
        let translation = CGPoint(x: (positionInScene?.x)! - (previousPosition?.x)!,
                                  y: (positionInScene?.y)! - (previousPosition?.y)!
        )
        
        panForTranslation(translation: translation)
        
    }
    
    
    
    private func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position
        
        if let name = selectedNode.name, name == Constants.movableNodeName {
            selectedNode.position = CGPoint(x: position.x + translation.x,
                                            y: position.y + translation.y
            )
            selectedNode.zPosition = 2
            
        }
        
    }
    
    private func selectNodeForTouch(touchLocation: CGPoint) {
        
        let touchedNode = self.atPoint(touchLocation)
        
        if touchedNode is SKSpriteNode {
            
            if !selectedNode.isEqual(touchedNode) {
                
                selectedNode = touchedNode as! SKSpriteNode
            }
        }
    }
    
}

extension PuzzleGameScene{
    
    func randomize(puzzlePieces: [SKSpriteNode], inFrame frame: CGRect )
    {
        let rotationAmountArray = [0.5, 1.0, 1.5, 2.0]
        
        for i in 0..<puzzlePieces.count {
            
            
            let puzzlePiece = puzzlePieces[i]
            
            let distance = 95
            
            if i < puzzlePieces.count/2 {
                
                puzzlePiece.position = CGPoint(x: frame.minX + CGFloat(i * distance),
                                               y: frame.maxY - 160)
            } else {
                puzzlePiece.position = CGPoint(x: frame.minX + CGFloat(i % 8 * distance),
                                               y: frame.minY + 160)
            }
            
            let randomRotationIndex = Int(arc4random_uniform(UInt32(rotationAmountArray.count)))
            puzzlePiece.zRotation = CGFloat(Double.pi) * CGFloat(rotationAmountArray[randomRotationIndex])
            
            puzzlePiece.name = Constants.movableNodeName
            self.addChild(puzzlePiece)
            
        }
        
    }
    
    func createPuzzlePieces(){
        
        if let image = UIImage(named: Constants.imageForPuzzle){
            
            if let imagesArray = PuzzleHelper.sliceImage(
                image: image,
                imageConversionSize: Constants.puzzleImageSize,
                puzzlePieceSize: Constants.puzzlePieceSize
                ){
                
                for i in 0..<imagesArray.count {
                    
                    let texture = SKTexture(image: imagesArray[i])
                    let puzzlePiece = SKSpriteNode(texture: texture)
                    
                    puzzlePieces.0.append(puzzlePiece)
                    
                }
                
                setCorrectPositions(inFrame: self.frame, forNumberOfPuzzlePieces: Constants.numberOfPuzzlePieces, ofPieceSize: Constants.puzzlePieceSize)
                
            }
            
        }
        
    }
    
    private func setCorrectPositions(inFrame: CGRect,forNumberOfPuzzlePieces numberOfPuzzlePieces: Int,ofPieceSize pieceSize: CGSize){
        
        let xPosition = inFrame.minX + pieceSize.width/2
        
        for i in 0 ..< numberOfPuzzlePieces {
            
            var correctionForX = CGFloat()
            var yPosition = CGFloat()
            
            if i < numberOfPuzzlePieces/4{
                correctionForX = CGFloat(i)*pieceSize.width
                yPosition = pieceSize.height/2*3
            }
            else if(i < 2*numberOfPuzzlePieces/4){
                correctionForX = CGFloat(i-4)*pieceSize.width
                yPosition = pieceSize.height/2
            }
                
            else if(i < 3*numberOfPuzzlePieces/4){
                correctionForX = CGFloat(i-8)*pieceSize.width
                yPosition = -pieceSize.height/2
            }
                
            else{
                correctionForX = CGFloat(i-12)*pieceSize.width
                yPosition = -pieceSize.height/2*3
            }
            
            puzzlePieces.1.append(CGPoint(x: xPosition + correctionForX, y: yPosition))
            
        }
        
    }
}

