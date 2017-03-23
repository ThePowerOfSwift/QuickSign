//
//  DrawingImageView.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class DrawingImageView: UIImageView {
    
    let LINE_COLOR: CGColor = UIColor.black.cgColor
    let LINE_WIDTH: CGFloat = 3.0
    
    var currentPoint = CGPoint.zero
    var prevPoint1 = CGPoint.zero
    var prevPoint2 = CGPoint.zero
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if let touch = touches.first{
            prevPoint1 = touch.previousLocation(in: self)
            prevPoint2 = touch.previousLocation(in: self)
            currentPoint = touch.location(in: self)
        }
    }
    // Helper function
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat((p1.x + p2.x) * 0.5), y: CGFloat((p1.y + p2.y) * 0.5))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            UIGraphicsBeginImageContext(self.frame.size)
            let context = UIGraphicsGetCurrentContext()
            
            prevPoint2 = prevPoint1
            prevPoint1 = touch.previousLocation(in: self)
            currentPoint = touch.location(in: self)
            
            let mid1: CGPoint = midPoint(p1: prevPoint1, p2: prevPoint2)
            let mid2: CGPoint = midPoint(p1: currentPoint, p2: prevPoint1)
            //self.image?.draw(in: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
            self.image?.draw(at: CGPoint.init(x:0,y:0), blendMode: .normal, alpha: 1.0)
            context?.move(to: CGPoint.init(x:mid1.x, y:mid1.y))
            context?.addQuadCurve(to: CGPoint.init(x:mid2.x, y:mid2.y), control: CGPoint.init(x:prevPoint1.x, y:prevPoint1.y))
            context?.setBlendMode(.normal)
            context?.setLineCap(CGLineCap.round)
            context?.setLineWidth(LINE_WIDTH)
            context?.strokePath()
            context?.setStrokeColor(LINE_COLOR)
            self.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
}
