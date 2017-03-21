//
//  Signature.swift
//  QuickSign
//
//  Created by mac on 2017-03-20.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class Signature: UIImageView {
    var lastLocation:CGPoint = CGPoint.init(x: 0, y: 0)
    let kResizeThumbSize:CGFloat = 45.0
    var touchLocation:CGPoint! = CGPoint.init(x: 0, y: 0)
    var isResizingLR: Bool = false
    var isResizeBtnDragged: Bool = false
    var isResizeBtnVisible: Bool = false
    var imageRatio: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //enable user interaction on self, important!
        self.isUserInteractionEnabled = true
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(detectPan))
        let tabRecognizer = UITapGestureRecognizer(target:self, action:#selector(detectTap))
        self.gestureRecognizers = [panRecognizer,tabRecognizer]
        
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

        //border color
        tappedView.layer.borderColor = UIColor.black.cgColor
        tappedView.layer.borderWidth = 2
        self.addSubview(tappedView)
        
        //add delete button to the subview
        let deleteButton = SignatureDeleteButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        deleteButton.addTarget(self, action: #selector(deleteButtonAction), for: .touchUpInside)
        //add resize button to the subview
        let resizeButton = SignatureResizeButton(frame: CGRect(x: self.bounds.maxX-30, y:self.bounds.maxY-30, width: 30, height: 30))
        resizeButton.addTarget(self, action: #selector(resizeButtonAction), for: .touchDragInside)
        
        tappedView.addSubview(deleteButton)
        tappedView.addSubview(resizeButton)
        tappedView.isUserInteractionEnabled = true
        tappedView.isHidden = true
        tappedView.tag = 99
        print(tappedView.tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    func deleteButtonAction(sender: SignatureDeleteButton!) {
        self.removeFromSuperview()
    }
    
    func resizeButtonAction(sender: SignatureResizeButton!, events: UIEvent) {
        print("resize button is being dragged")
        let touches = events.touches(for:sender)! as Set<UITouch>
        let containerVw = self
        let tappedView = self.subviews.first
        let resizeBtn = self.subviews.first?.subviews.last
        
        if let touch = touches.first {
            touchLocation = touch.location(in:self)
        }
        
        
        isResizingLR = (self.bounds.size.width - touchLocation.x < kResizeThumbSize && self.bounds.size.height - touchLocation.y < kResizeThumbSize);
        
        isResizeBtnVisible = !(self.subviews.first?.isHidden)!
        
        print("Are you dragging the corner?")
        print(isResizingLR)
        
        let deltaWidth:CGFloat = touchLocation.x-lastLocation.x;
        
        if (isResizingLR && isResizeBtnVisible) {
            print("resizing")
            containerVw.frame = CGRect(x:(containerVw.frame.origin.x), y:(containerVw.frame.origin.y), width:touchLocation.x + deltaWidth, height:touchLocation.x + deltaWidth);
            tappedView?.frame = (tappedView?.superview?.bounds)!
            resizeBtn?.frame = CGRect(x:self.bounds.maxX-30, y: self.bounds.maxY-30, width:30, height:30 );
        }
        
        if (!isResizingLR) {
            print("not resizing")
            containerVw.center = CGPoint.init(x:(containerVw.center.x) + touchLocation.x -  lastLocation.x, y:(containerVw.center.y) + touchLocation.y - lastLocation.y);
        }
    }

    func detectPan(recognizer:UIPanGestureRecognizer) {
        let translation  = recognizer.translation(in: self.superview!)

        self.center = CGPoint.init(x: lastLocation.x + translation.x, y: lastLocation.y + translation.y)

    }
    
    func detectTap(recognizer:UITapGestureRecognizer) {
        //show button on touch
        self.subviews.first?.isHidden = !(self.subviews.first?.isHidden)!;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Bring the touched view to the front
        self.superview?.bringSubview(toFront: self)
        
        // Remember original location
        lastLocation = self.center

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

//        let containerVw = self
//        let tappedView = self.subviews.first
//        let resizeBtn = self.subviews.first?.subviews.last
//        
//        if let touch = touches.first {
//            touchLocation = touch.location(in:self)
//        }
//        
//        isResizingLR = (self.bounds.size.width - touchLocation.x < kResizeThumbSize && self.bounds.size.height - touchLocation.y < kResizeThumbSize);
//        
//        isResizeBtnVisible = !(self.subviews.first?.isHidden)!
//        
//        print("Are you dragging the corner?")
//        print(isResizingLR)
//        
//        let deltaWidth:CGFloat = touchLocation.x-lastLocation.x;
//        
//        if (isResizingLR && isResizeBtnVisible) {
//            print("resizing")
//            containerVw.frame = CGRect(x:(containerVw.frame.origin.x), y:(containerVw.frame.origin.y), width:touchLocation.x + deltaWidth, height:touchLocation.x + deltaWidth);
//            tappedView?.frame = (tappedView?.superview?.bounds)!
//            resizeBtn?.frame = CGRect(x:self.bounds.maxX-30, y: self.bounds.maxY-30, width:30, height:30 );
//        }
//        
//        if (!isResizingLR) {
//            print("not resizing")
//            containerVw.center = CGPoint.init(x:(containerVw.center.x) + touchLocation.x -  lastLocation.x, y:(containerVw.center.y) + touchLocation.y - lastLocation.y);
//        }
        
    }
    
}
