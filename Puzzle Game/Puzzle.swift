//
//  Model.swift
//  Puzzle Game
//
//  Created by Sebastian Waloszek on 03/08/2017.
//  Copyright © 2017 SW. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class Puzzle{
    
    private struct Constants{
        static let puzzlePiecesXOffset = 95
        static let puzzlePiecesYOffset = 160
        
    }
    
    var puzzlePieces = (piece: [SKSpriteNode](), correctPosition: [CGPoint]())
    
    //Positions and randomly rotate puzzle pieces
    func positionAndRotatePuzzlePieces(withName name: String, inFrame frame: CGRect)
    {
        
        let rotationAmountArray = [0.5, 1.0, 1.5,2.0]
        
        //Go through every puzzle piece
        for i in 0..<puzzlePieces.0.count {
            
            let puzzlePiece = puzzlePieces.0[i]
            
            //First half of puzzle pieces is placed on top
            if i < puzzlePieces.0.count/2 {
                
                puzzlePiece.position = CGPoint(x: frame.minX + CGFloat(i * Constants.puzzlePiecesXOffset),
                                               y: frame.maxY - Constants.puzzlePiecesYOffset)
            }
                //Second half of puzzle pieces is placed on bottom
            else {
                puzzlePiece.position = CGPoint(x: frame.minX + CGFloat(i % 8 * Constants.puzzlePiecesXOffset),
                                               y: frame.minY + Constants.puzzlePiecesYOffset)
            }
            
            let randomRotationIndex = Int(arc4random_uniform(UInt32(rotationAmountArray.count)))
            puzzlePiece.zRotation = CGFloat(Double.pi) * CGFloat(rotationAmountArray[randomRotationIndex])
            
            //Make the puzzle piece movable
            puzzlePiece.name = name
            
        }
        
    }
    
    //Create puzzle pieces and fill the puzzlePieces array
    func createPuzzlePieces(fromImage image: UIImage,forImageConversionSize imageConversionSize:CGSize,forPuzzleSize puzzleSize: CGSize){
        
        //Get the array of images from the sliced image.
        if let slicedImages = PuzzleHelper.sliceImage(
            image: image,
            imageConversionSize: imageConversionSize,
            puzzlePieceSize: puzzleSize
            ){
            
            //Go through all the image items
            for i in 0..<slicedImages.count {
                
                //Create the SKSpiriteNode of the puzzle piece
                let texture = SKTexture(image: slicedImages[i])
                let puzzlePiece = SKSpriteNode(texture: texture)
                
                //Add the puzzle piece the array of all pieces
                puzzlePieces.0.append(puzzlePiece)
                
            }
        }
    }
    
    //Set correct position for every puzzle piece
    func setCorrectPositions(inFrame: CGRect,forNumberOfPuzzlePieces numberOfPuzzlePieces: Int,ofPieceSize pieceSize: CGSize){
        
        //Set base X position
        let xPosition = inFrame.minX + pieceSize.width/2
        
        //Go through all the puzzle pieces
        for i in 0 ..< numberOfPuzzlePieces {
            
            var correctionForX = CGFloat()
            var yPosition = CGFloat()
            
            //get position for first row puzzle pieces
            if i < numberOfPuzzlePieces/4{
                
                correctionForX = CGFloat(i) * pieceSize.width
                yPosition = pieceSize.height / 2 * 3
                
            }
                
                //get position for second row puzzle pieces
            else if(i < 2 * numberOfPuzzlePieces/4){
                
                correctionForX = CGFloat(i - 4) * pieceSize.width
                yPosition = pieceSize.height/2
                
            }
                
                //get position for third row puzzle pieces
            else if(i < 3 * numberOfPuzzlePieces/4){
                
                correctionForX = CGFloat(i - 8) * pieceSize.width
                yPosition = -pieceSize.height/2
                
            }
                //get position for forth row puzzle pieces
            else{
                
                correctionForX = CGFloat(i - 12) * pieceSize.width
                yPosition = -pieceSize.height/2 * 3
                
            }
            
            let correctPosition = CGPoint(x: xPosition + correctionForX, y: yPosition)
            
            if puzzlePieces.1.count != numberOfPuzzlePieces {
                //Add correct positions to puzzlePieces
                puzzlePieces.1.append(correctPosition)
            }
            else{
                puzzlePieces.1[i] = correctPosition
            }
            
        }
    }
    
}
