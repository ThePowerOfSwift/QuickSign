//  resources: http://stackoverflow.com/questions/8460119/how-to-resize-uiview-by-dragging-from-its-edges
//  Signature.swift
//  QuickSign
//
//  Created by mac on 2017-03-20.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class Signature: UIImageView {
    let resizeThumbSize:CGFloat  = 20.0
    let btnWidth:CGFloat         = 30.0
    let widthContraint:CGFloat   = 30.0
    var ratio:CGFloat            = 1.0
    var isResizeBtnVisible:Bool  = false
    var isResizingLR:Bool        = false
    var lastLocation:CGPoint     = CGPoint.init(x: 0, y: 0)
    var touchWhenBegan:CGPoint!  = CGPoint.init(x: 0, y: 0)
    var touchWhenMoved:CGPoint!  = CGPoint.init(x: 0, y: 0)

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //important!
        //self.isMultipleTouchEnabled = false
        self.isUserInteractionEnabled = true
        //let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        let tabRecognizer = UITapGestureRecognizer(target:self, action:#selector(detectTap))
        self.gestureRecognizers = [tabRecognizer]
        
        //adding the signature saved eariler
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath+"/MySignature").appendingPathComponent("/signatureSample.png")
                print(imageURL)
            let image    = UIImage(contentsOfFile: imageURL.path)
            self.image = image
        }
        //add tapped view with buttons & border
        let tappedView = UIView(frame: CGRect(x:0, y:0, width:self.frame.size.width, height: self.frame.size.height))
        tappedView.layer.borderColor = UIColor.purple.cgColor
        tappedView.layer.borderWidth = 2
        self.addSubview(tappedView)
        
        //add delete button to the subview
        let deleteButton = SignatureDeleteButton(frame: CGRect(x: 0, y: 0, width: btnWidth, height: btnWidth))
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        //add resize button to the subview
        let resizeButton = SignatureResizeButton(frame: CGRect(x: self.bounds.maxX-btnWidth, y:self.bounds.maxY-btnWidth, width: btnWidth, height: btnWidth))
        resizeButton.isUserInteractionEnabled = false
        //resizeButton.addTarget(self, action: #selector(resizeButtonAction), for: .touchDragInside)
        //resizeButton.addTarget(self, action: #selector(resizeButtonAction), for: .touchDragInside)
        tappedView.addSubview(deleteButton)
        tappedView.addSubview(resizeButton)
        tappedView.isUserInteractionEnabled = true
        tappedView.tag = 99
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func deleteButtonAction(sender: SignatureDeleteButton!) {
        self.removeFromSuperview()
    }
    
    func resizeButtonAction(sender: SignatureResizeButton!, events: UIEvent) {
        //Nothing here
    }
    
    func detectTap(recognizer:UITapGestureRecognizer) {
        // Toggle: show/hide button on tap
        self.subviews.first?.isHidden = !(self.subviews.first?.isHidden)!;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Bring the touched view to the front
        self.superview?.bringSubview(toFront: self)
        // Prepare for resizing
        if let touch = touches.first {
            touchWhenBegan = touch.location(in: self)
        }
        
        if (self.subviews.first?.isHidden)! == false {
            isResizeBtnVisible = true
        }else{
            isResizeBtnVisible = false
        }
        
        isResizingLR = (self.bounds.size.width - touchWhenBegan.x < resizeThumbSize && self.bounds.size.height - touchWhenBegan.y < resizeThumbSize)
        
        let width:CGFloat  = self.frame.size.width;
        let height:CGFloat = self.frame.size.height;
        ratio = width/height

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touches = events.touches(for:sender)! as Set<UITouch>
        let deltaWidth:CGFloat = touchWhenMoved.x - touchWhenBegan.x;
        let x:CGFloat = self.frame.origin.x;
        let y:CGFloat = self.frame.origin.y;
        let containerVw = self
        let tappedView = self.subviews.first
        let resizeBtn = self.subviews.first?.subviews.last
        
        if let touch = touches.first {
            touchWhenMoved = touch.location(in: self)
        }

        if (isResizingLR) {
            print("resizing")

            if containerVw.frame.width >= widthContraint {
                containerVw.frame = CGRect(x:x,
                                           y:y,
                                           width:touchWhenMoved.x+deltaWidth/10,
                                           height:(touchWhenMoved.x+deltaWidth/10)/ratio)
            }
            if (containerVw.frame.width < widthContraint){
                containerVw.frame = CGRect(x:x, y:y, width:widthContraint, height:widthContraint/ratio);
            }
            if (containerVw.frame.height < widthContraint){
                containerVw.frame = CGRect(x:x, y:y, width:widthContraint*ratio, height:widthContraint);
            }
            tappedView?.frame = (tappedView?.superview?.bounds)!
            resizeBtn?.frame = CGRect(x:self.bounds.maxX-btnWidth, y: self.bounds.maxY-btnWidth, width:btnWidth, height:btnWidth );

        } else{
            if isResizeBtnVisible {
                let midPointX: CGFloat = self.bounds.midX
                let midPointY: CGFloat = self.bounds.midY
                var newPoint = CGPoint(x: self.center.x + ((touchWhenMoved?.x)! - touchWhenBegan.x), y: self.center.y + ((touchWhenMoved?.y)! - touchWhenBegan.y))
                //-----------restrain signature within superview----------
                if newPoint.x > (self.superview?.bounds.size.width)! - midPointX {
                    newPoint.x = (self.superview?.bounds.size.width)! - midPointX
                }else if newPoint.x < midPointX {
                    newPoint.x = midPointX
                }
                
                if newPoint.y > (self.superview?.bounds.size.height)! - midPointY {
                    newPoint.y = (self.superview?.bounds.size.height)! - midPointY
                }else if newPoint.y < midPointY {
                    newPoint.y = midPointY
                }
                
                self.center = newPoint
            }
        }
    }
}
