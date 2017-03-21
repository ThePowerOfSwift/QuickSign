//
//  DrawingImageView.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class DrawingImageView: UIImageView {

    var lastPoint = CGPoint.zero
    var swipped = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipped = false
        
        if let touch = touches.first{
            lastPoint = touch.location(in: self)
        }
    }
    
    func drawLines(fromPoint: CGPoint, toPoint: CGPoint){
        UIGraphicsBeginImageContext(self.frame.size)
        self.image?.draw(in: CGRect(x:0,
                                    y:0,
                                    width: self.frame.width,
                                    height:self.frame.height))
        let context = UIGraphicsGetCurrentContext()
        context?.move(to: CGPoint(x:fromPoint.x, y:fromPoint.y))
        context?.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        context?.setBlendMode(CGBlendMode.normal)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(5)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.strokePath()
        
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swipped = true
        
        if let touch = touches.first{
            let currentPoint = touch.location(in:self)
            drawLines(fromPoint: lastPoint, toPoint: currentPoint)
            lastPoint = currentPoint
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swipped {
            drawLines(fromPoint: lastPoint, toPoint: lastPoint)
        }
    }


}
