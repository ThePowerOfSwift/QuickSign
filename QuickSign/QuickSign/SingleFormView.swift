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
    let initHorizontalWidth:CGFloat = 60.0
    let initVerticalHeight:CGFloat = 50.0
    var ratio:CGFloat = 1.0
    var image: UIImage? = nil
    var isSignatureCreated: Bool?
    var destinationMessage: String = ""
    var newView:Signature = Signature(frame: CGRect.init())
    
    @IBAction func AddSignature(_ sender: Any) {
        if(!isSignatureCreated!){
            alertNoSignature()
            return
        }else{

            var width:CGFloat = 0.0
            var height:CGFloat = 0.0
            if (ratio>1){
                //if horizontal
                width = initHorizontalWidth
                if(width/ratio < 30.0){
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: 30*ratio, height:30 ))
                }else{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: width, height:width/ratio ))
                }

            }else{
                //if vertical
                height = initVerticalHeight
                if height*ratio<30.0{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: 30, height:30/ratio ))
                }else{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: height*ratio, height:height ))
                }

            }

            formImageView.addSubview(newView)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        formImageView.image = image
        //important!
        formImageView.isUserInteractionEnabled = true

        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath+"/MySignature").appendingPathComponent("/signatureSample.png")
            let image    = UIImage(contentsOfFile: imageURL.path)
            if(image?.size.width != nil){
                isSignatureCreated = true
                ratio = (image?.size.width)!/(image?.size.height)!
                self.image = image
                print("existing ratio")
                print(ratio)
            }else{
                isSignatureCreated = false
            }
            
        }
    }

    //update the signature width
    override func viewWillAppear(_ animated: Bool) {
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
    func alertNoSignature(){
        let alert = UIAlertController(title: "Cannot Add",
                                      message: "No Signature created", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "I understand", style: .default) {
            (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
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
