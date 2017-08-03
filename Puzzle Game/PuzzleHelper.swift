//
//  Puzzle.swift
//  Puzzle Game
//
//  Created by Sebastian Waloszek on 02/08/2017.
//  Copyright © 2017 SW. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class PuzzleHelper{

    static func sliceImage(image: UIImage,imageConversionSize: CGSize,puzzlePieceSize: CGSize) -> [UIImage]?{
        
        if let wholeImage = resize(image: image,toSize: imageConversionSize){
            
            let imagesCountInLine = Int((imageConversionSize.width) / puzzlePieceSize.width)
            let piecesCount = Int(imagesCountInLine * imagesCountInLine)
            
            var line = 0
            var row = 0
            
            var imagesArray = [UIImage]()
            
            for _ in 0 ..< piecesCount {
                
                let cgImg = wholeImage.cgImage!.cropping(
                    to: CGRect(x: CGFloat(row) * puzzlePieceSize.width,
                               y: CGFloat(line) * puzzlePieceSize.height,
                               width: puzzlePieceSize.width,
                               height: puzzlePieceSize.height)
                )
                
                let image = UIImage(cgImage: cgImg!)
                
                imagesArray.append(image)
                
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
        
        return nil
        
    }
    
    
    static private func resize(image : UIImage, toSize size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContext(size)
        
        if let context = UIGraphicsGetCurrentContext(){
            context.translateBy(x: 0.0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0);
            
            context.draw(image.cgImage!, in: CGRect(x: 0.0,
                                                    y: 0.0,
                                                    width: size.width,
                                                    height: size.height)
            )
        }
        
        if let scaledImage = UIGraphicsGetImageFromCurrentImageContext(){
            UIGraphicsEndImageContext()
            return scaledImage
        }
        
        return nil
        
    }
    


    
    
}
