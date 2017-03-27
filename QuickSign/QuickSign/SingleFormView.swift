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
    let minSignatureSize:CGFloat = 30.0
    var ratio:CGFloat = 1.0
    var image: UIImage? = nil
    var isSignatureCreated: Bool?
    var destinationMessage: String = ""
    var newView:Signature = Signature(frame: CGRect.init())
    var imageName:String?
    var isSubViewExist:Bool?
    var isSignatureExist:Bool?

    /*-----------------------------------------
    *           Overrid Functions
    *----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()

        formImageView.image = image
        formImageView.isUserInteractionEnabled = true
        formImageView.contentMode = UIViewContentMode.scaleAspectFit;

        self.checkFolderExists("/MyFormViews")
        self.checkFolderExists("/MySignature")
        self.checkSignatureCreated()
        //self.loadSubViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //force portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Monitor signature changes
        self.checkSignatureCreated()
        //self.loadSubViews()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // Save subviews
        //self.saveSubViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If tab elsewhere (not signature) then buttons disappear
        if let touch = touches.first {
            if touch.view?.tag != 99 {
                for v in (formImageView.subviews) {
                    v.subviews.first?.isHidden = true
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*-----------------------------------------
     *           Gesture Action
     *----------------------------------------*/
    
    @IBAction func scaleForm(_ sender: UIPinchGestureRecognizer) {
        formImageView.transform = formImageView.transform
            .scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    /*-----------------------------------------
     *           Button Action
     *----------------------------------------*/
    
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
                if(width/ratio < minSignatureSize){
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: minSignatureSize*ratio, height:minSignatureSize ))
                }else{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: width, height:width/ratio ))
                }
                
            }else{
                //if vertical
                height = initVerticalHeight
                if height*ratio < minSignatureSize{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: minSignatureSize, height:minSignatureSize/ratio ))
                }else{
                    newView = Signature(frame: CGRect.init(x: formImageView.bounds.size.width/2, y: formImageView.bounds.size.height/2, width: height*ratio, height:height ))
                }
            }
            newView.tag = 100
            formImageView.addSubview(newView)
        }
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        let allSignatures = formImageView.subviews
        //if any signatures are added
        if allSignatures.count != 0 {
            for oneSignature in allSignatures {
                oneSignature.subviews.first?.isHidden = true
            }
            UIGraphicsBeginImageContextWithOptions(formImageView.bounds.size, true, 0.0)
            formImageView.drawHierarchy(in: formImageView.bounds, afterScreenUpdates: true)
            let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(snapshotImageFromMyView!, nil, nil, nil);
        }else{
            //TO DO: Add Alert
        }
    }
    
    @IBAction func deleteForm(_ sender: Any) {

        let fileManager = FileManager.default
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
                return
        }
        let filePath = "\(dirPath)/MyAppImages/\(imageName!)"
        do {
            try fileManager.removeItem(atPath: filePath)
        } catch let error as NSError {
            print("CANNOT DELETE IMAGE")
            print(error.debugDescription)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Load Table"), object: nil)
    }
    
    /*-----------------------------------------
     *           Helper Functions
     *----------------------------------------*/
    
    func checkSignatureCreated(){
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
        let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        
        if let dirPath          = paths.first
        {
            let imageURL = URL(fileURLWithPath: dirPath+"/MySignature").appendingPathComponent("signatureSample.png")
            let image    = UIImage(contentsOfFile: imageURL.path)
            if(image?.size.width != nil){
                isSignatureCreated = true
                ratio = (image?.size.width)!/(image?.size.height)!
                self.image = image
            }else{
                isSignatureCreated = false
            }
        }
    }
    
    func checkFolderExists(_ folderName: String){
        var objcBool:ObjCBool = true
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let subViewDirectoryPath = path.appendingFormat(folderName)
        let isSubViewExist = FileManager.default.fileExists(atPath: subViewDirectoryPath, isDirectory: &objcBool)
        
        if isSubViewExist == false{
            do{
                try FileManager.default.createDirectory(atPath: subViewDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a folder")
            }
        }
    }
    
    func saveSubViews(){
//        print("saving subviews")
//        if(self.view.viewWithTag(100) != nil){
//            let filename = trimImageName(imageName!) + "-subviews"
//            //let dataToSave = NSKeyedArchiver.archivedData(withRootObject: formImageView )
//            let fullPath = getDocumentsDirectory().appendingPathComponent("MyFormViews", isDirectory: true).appendingPathComponent(filename)
//            do {
//                //try dataToSave.write(to: fullPath)
//                try NSKeyedArchiver.archiveRootObject(formImageView.subviews as! [Signature], toFile: fullPath.path)
//                print("Saved to path")
//                print(fullPath)
//            } catch {
//                print("Couldn't write file")
//            }
//        }
    }
    
    func loadSubViews(){
//        print("loading subviews")
//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
//        let url = NSURL(fileURLWithPath: path)
//        //load subviews if exists
//        let filename = trimImageName(imageName!) + "-subviews"
//        let filePath = url.appendingPathComponent("MyFormViews", isDirectory: true)?.appendingPathComponent(filename)
//        let fileManager = FileManager.default
//        
//        if fileManager.fileExists(atPath: filePath!.path) {
//            print("SUBVIEW FILE EXISTS")
//            print((filePath?.absoluteString)!)
//            //let subViews = NSKeyedUnarchiver.unarchiveObject(withFile: (filePath?.absoluteString)!) as? UIImageView
//            let subViews = NSKeyedUnarchiver.unarchiveObject(withFile: (filePath?.absoluteString)!) as? [Signature]
//            for subView in subViews! {
//                    print("add subviews")
//                    subView.tag = 100
//                    formImageView.addSubview(subView)
//            }
//        } else {
//            print("SUBVIEW FILE NOT AVAILABLE")
//        }
    }
    
    // Trim ".png" off ImageName
    func trimImageName (_ str: String) -> String{
        let start = str.index(str.startIndex, offsetBy: 0)
        let end = str.index(str.endIndex, offsetBy: -4)
        let range = start..<end
        
        return str.substring(with: range)
    }
    
    // Helper Function: get document directory
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths.first
        return documentsDirectory!
    }
    
    // Alert if no signature has been created
    func alertNoSignature(){
        let alert = UIAlertController(title: "Cannot Add",
                                      message: "No Signature created", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "I understand", style: .default) {
            (alert: UIAlertAction!) -> Void in
        }
        alert.addAction(firstAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
