// flipping axis http://stackoverflow.com/questions/13153223/how-to-crop-the-image-using-uibezierpath
//  DrawingImageView.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class DrawingImageView: UIView {
    
    var lineColor: UIColor?
    var lineWidth: CGFloat = 0.0
    var isEmpty: Bool = false
    var canvasImage: UIImage?
    var currentPoint = CGPoint.zero
    var previousPoint = CGPoint.zero
    var previousPreviousPoint = CGPoint.zero
    var path: CGMutablePath? = nil
    
    let DEFAULT_COLOR = UIColor.black
    let DEFAULT_WIDTH = 5.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        path = CGMutablePath()
        lineWidth = CGFloat(DEFAULT_WIDTH)
        lineColor = DEFAULT_COLOR
        isEmpty = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        path = CGMutablePath()
        lineWidth = CGFloat(DEFAULT_WIDTH)
        lineColor = DEFAULT_COLOR
        isEmpty = true
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.normal)
        context?.addPath(path!)
        context?.setLineCap(CGLineCap.round)
        context?.setLineWidth(CGFloat(self.lineWidth))
        context?.strokePath()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            self.previousPoint = touch.previousLocation(in: self)
            self.previousPreviousPoint = touch.previousLocation(in: self)
            self.currentPoint = touch.location(in: self)
            self.touchesMoved(touches, with: event!)
        }
    }
    // Helper function
    func midPoint(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: CGFloat((p1.x + p2.x) * 0.5), y: CGFloat((p1.y + p2.y) * 0.5))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            
            self.previousPreviousPoint = self.previousPoint
            self.previousPoint = touch.previousLocation(in: self)
            self.currentPoint = touch.location(in: self)
            let mid1: CGPoint = midPoint(p1: self.previousPoint, p2: self.previousPreviousPoint)
            let mid2: CGPoint = midPoint(p1: self.currentPoint, p2: self.previousPoint)
            let subpath: CGMutablePath = CGMutablePath()
            subpath.move(to: CGPoint(x: CGFloat(mid1.x), y: CGFloat(mid1.y)), transform: .identity)
            subpath.addQuadCurve(to: CGPoint(x: CGFloat(mid2.x), y: CGFloat(mid2.y)), control: CGPoint(x: CGFloat(self.previousPoint.x), y: CGFloat(self.previousPoint.y)), transform: .identity)
            let bounds: CGRect = subpath.boundingBox
            let drawBox: CGRect = bounds.insetBy(dx: CGFloat(-0.5 * self.lineWidth), dy: CGFloat(-0.5 * self.lineWidth))
            path?.addPath(subpath, transform: .identity)
            self.setNeedsDisplay(drawBox)
            
        }
    }
    
    func getTheImage() -> UIImage {
        
        var imageSize = (self.path?.boundingBox.size)!
        print("boundingbox size")
        print(imageSize)
        imageSize.width += lineWidth*2
        imageSize.height += lineWidth*2
        print("boundingbox size")
        print(imageSize)

        UIGraphicsBeginImageContext(imageSize)
        let context = UIGraphicsGetCurrentContext()

        // translate matrix so that path will be centered in bounds
        context?.translateBy(x: -((self.path?.boundingBox.origin.x)! - lineWidth), y: -((self.path?.boundingBox.origin.y)! - lineWidth))
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func clearImage(){
        currentPoint = CGPoint.zero
        previousPoint = CGPoint.zero
        previousPreviousPoint = CGPoint.zero
        path = CGMutablePath()
        self.setNeedsDisplay()
    }
    
}
