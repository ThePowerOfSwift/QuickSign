//
//  SignatureResizeButton.swift
//  QuickSign
//
//  Created by mac on 2017-03-20.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class SignatureResizeButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        let deleteImage = UIImage(named: "arrow-purple.png")! as UIImage
        
        self.setBackgroundImage(deleteImage, for: .normal)
        self.isUserInteractionEnabled = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
