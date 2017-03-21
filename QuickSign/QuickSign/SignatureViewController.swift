//
//  SignatureViewController.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class SignatureViewController: UIViewController {
    @IBOutlet weak var myImageView: UIImageView!
    var signatureDirectoryPath:String!
    
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

    
    @IBAction func clearSignature(_ sender: Any) {
        self.myImageView.image = nil
    }
    
    @IBAction func saveSignature(_ sender: Any) {
        
//        if let image = self.myImageView.image {
//            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        }
        var imagePath = "signatureSample"
        imagePath = signatureDirectoryPath.appending("/\(imagePath).png")
        let data = UIImagePNGRepresentation(self.myImageView.image!)
        FileManager.default.createFile(
            atPath: imagePath,
            contents: data,
            attributes:nil
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


}
