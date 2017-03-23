//
//  SingleFormView.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class SingleFormView: UIViewController {
    @IBOutlet weak var formImageView: UIImageView!
    var ratio:CGFloat = 1.0
    var image: UIImage? = nil
    var destinationMessage: String = ""
    
    @IBAction func AddSignature(_ sender: Any) {
        
        //let newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: 100, height: 100))
        
        let newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: 100, height:100/ratio ))

        formImageView.addSubview(newView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        formImageView.image = image
        //important!
        formImageView.isUserInteractionEnabled = true
        //get the ratio
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath+"/MySignature").appendingPathComponent("/signatureSample.png")
            print(imageURL)
            let image    = UIImage(contentsOfFile: imageURL.path)
            ratio = (image?.size.width)!/(image?.size.height)!
            self.image = image
            print("existing ratio")
            print(ratio)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view?.tag != 99 {
                for v in (formImageView.subviews) {
                    v.subviews.first?.isHidden = true
                }
            }
        }
    }
}
