//
//  SignatureViewController.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController {
    //@IBOutlet weak var myImageView: UIImageView!
    var signatureDirectoryPath:String!

    @IBOutlet weak var myImageView: DrawingImageView!
    var signatureImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Create Signature"
        createDirectory()
        // Do any additional setup after loading the view.
        myImageView.layer.borderColor = UIColor.black.cgColor
        myImageView.layer.borderWidth = 2
        myImageView.isUserInteractionEnabled = true
        myImageView.isOpaque = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
  
    @IBAction func clearSignature(_ sender: Any) {
        //self.myImageView.image = nil
        self.myImageView.clearImage()
    }
    
    @IBAction func saveSignature(_ sender: Any) {
        var imagePath = "signatureSample"
        imagePath = signatureDirectoryPath.appending("/\(imagePath).png")
        //if(self.myImageView.image == nil){
//        alertNoSignatureSaved()
//        return
//    }
        //let data = UIImagePNGRepresentation(self.myImageView.image!)
        let signatureImage = myImageView?.getTheImage()
        if(signatureImage == nil){
            alertNoSignatureSaved()
            return
        }
        let data = UIImagePNGRepresentation(signatureImage!)
        FileManager.default.createFile(
            atPath: imagePath,
            contents: data,
            attributes:nil
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func createDirectory(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        signatureDirectoryPath = documentDirectorPath.appendingFormat("/MySignature")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: signatureDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: signatureDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        print(signatureDirectoryPath)
    }
    func alertNoSignatureSaved(){
        let alert = UIAlertController(title: "Cannot Save",
                                      message: "No Signature created", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "I understand", style: .default) {
            (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
