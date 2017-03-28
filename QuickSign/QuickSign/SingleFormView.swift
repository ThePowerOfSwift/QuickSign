//
//  SingleFormView.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit
import MessageUI

class SingleFormView: UIViewController, UIWebViewDelegate, UIScrollViewDelegate,MFMailComposeViewControllerDelegate {
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
    var webView = UIWebView()

    /*-----------------------------------------
    *           Overrid Functions
    *----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()

        formImageView.image = image
        formImageView.isUserInteractionEnabled = true
        formImageView.contentMode = UIViewContentMode.scaleAspectFit;
        webView.delegate = self
        
        self.checkFolderExists("/MyFormViews")
        self.checkFolderExists("/MySignature")
        self.checkSignatureCreated()
        self.loadPDFifExist()

        let browserView = webView.scrollView
        print(browserView.contentSize.height)

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //force portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        // Monitor signature size changes
        self.checkSignatureCreated()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        // Nothing Here
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
        //get current page number
        print("current page")
        let currentPageNum = self.getActualPageNum()
        print(currentPageNum)
        if(!isSignatureCreated!){
            alertNoSignature()
            return
        }else{
            let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
            let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
            guard let dirPath = paths.first else {
                return
            }
            
            let pdfLocation = self.trimImageName(imageName!) + ".pdf"
            let pdfPath = "\(dirPath)/MyAppImages/\(pdfLocation)"
            var objcBool:ObjCBool = false
            let isExist = FileManager.default.fileExists(atPath: pdfPath, isDirectory: &objcBool)
            
            if isExist{
                self.initSubView(webView.scrollView.subviews.first!)
                webView.scrollView.addSubview(newView)
            }else{
                self.initSubView(formImageView)
                formImageView.addSubview(newView)
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveToCameraRoll(_ sender: Any) {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }
        
        let pdfLocation = self.trimImageName(imageName!) + ".pdf"
        let oldPdfPath = "\(dirPath)/MyAppImages/\(pdfLocation)"
        var objcBool:ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: oldPdfPath, isDirectory: &objcBool)
        if isExist {
            //save new pdf in export folder
            self.saveToPdf(oldPdfPath)
            print("pdf saved")
//            if MFMailComposeViewController.canSendMail() {
//                let mc = MFMailComposeViewController()
//                mc.mailComposeDelegate = self
//                let newFilePath = "\(dirPath)/MyExportFiles/\(pdfLocation)"
//                let fileData = NSData(contentsOfFile: newFilePath)
//                
//                mc.addAttachmentData(fileData as! Data, mimeType: "application/pdf", fileName: pdfLocation)
//                self.present(mc, animated: true, completion: nil)
//            } else {
//                // show failure alert
//            }

        } else{
            self.saveToCamera()
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
        let imageLocation = self.trimImageName(imageName!) + ".png"
        let imagePath = "\(dirPath)/MyAppImages/\(imageLocation)"
        do {
            try fileManager.removeItem(atPath: imagePath)
        } catch let error as NSError {
            print("CANNOT DELETE IMAGE")
            print(error.debugDescription)
        }
        // if a pdf with the same name exist
        let pdfLocation = self.trimImageName(imageName!) + ".pdf"
        let pdfPath = "\(dirPath)/MyAppImages/\(pdfLocation)"
        var objcBool:ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: pdfPath, isDirectory: &objcBool)
        if isExist{
            do {
                try fileManager.removeItem(atPath: pdfPath)
            } catch let error as NSError {
                print("CANNOT DELETE PDF")
                print(error.debugDescription)
            }
        }
        // TO DO: go back to previous controller after deletion
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Load Table"), object: nil)
    }
    
    /*-----------------------------------------
     *           Helper Functions
     *----------------------------------------*/
    func getActualPageNum() -> Int {
        let scrollViewHeight: Float = Float(webView.frame.size.height)
        let pageOffset: Float = Float(webView.scrollView.contentOffset.y)
        let windowRect:CGRect = self.view.window!.frame
        let windowHeight:Float = Float(windowRect.size.height);
        let zoom:Float = Float(webView.scrollView.zoomScale)
        let pageNum = ceilf(((pageOffset + windowHeight/2) / scrollViewHeight)/zoom)
        return Int(pageNum);
    }
    func saveToPdf(_ oldpath:String) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectorPath:String = paths[0]
        let fileName = self.trimImageName(imageName!) + ".pdf"
        self.checkFolderExists("/MyExportFiles")
        let newPath = documentDirectorPath.appendingFormat("/MyExportFiles/").appending(fileName)
        
        //new path
        UIGraphicsBeginPDFContextToFile(newPath, CGRect.zero, nil);
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRect.init(x:0, y:0, width:612, height:792), nil);
        
        //open template file
        let url = URL(string: "file://" + oldpath)
        let templateDocument:CGPDFDocument = CGPDFDocument(url as! CFURL)!;
        
        //get bounds of template page
        var templatePage:CGPDFPage = templateDocument.page(at: 1)!;
        let templatePageBounds:CGRect = templatePage.getBoxRect(CGPDFBox(rawValue: 1)!);
        
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        
        //flip context due to different origins, important
        context.translateBy(x: 0.0, y: templatePageBounds.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        
        //copy content of template page on the corresponding page in new file
        context.drawPDFPage(templatePage);
        
        //flip context back, important
        context.translateBy(x: 0.0, y: templatePageBounds.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        
        // add the signature
        let signature:UIView? = webView.scrollView.viewWithTag(100)
        let signX = signature!.frame.origin.x
        let signY = signature!.frame.origin.y
        let superView:UIView = signature!.superview!

        let heightDiff = formImageView.frame.maxY - superView.frame.maxY

        let uiImage = self.convertToImage(signature!)
        let contextCI = CIContext()
        let inputImage = CIImage(image: uiImage)
        let logo:CGImage = contextCI.createCGImage(inputImage!, from: inputImage!.extent)!
        
        let frame = CGRect.init(x: signX, y: signY+heightDiff, width: uiImage.size.width, height: uiImage.size.height)
        context.draw(logo, in: frame)
        
        // get the 2nd page
        templatePage = templateDocument.page(at: 2)!;
        UIGraphicsBeginPDFPageWithInfo(CGRect.init(x:0, y:0, width:612, height:792), nil);
        context.translateBy(x: 0.0, y: templatePageBounds.size.height);
        context.scaleBy(x: 1.0, y: -1.0);
        context.drawPDFPage(templatePage);
        
        // Close the PDF context and write the contents out.
        UIGraphicsEndPDFContext();
        
    }
    
    func convertToImage(_ subView:UIView) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(subView.bounds.size, false, 0.0)
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: subView.bounds.size.height);
        context?.scaleBy(x: 1, y: -1);
        subView.layer.render(in: context!)
        context?.translateBy(x: 0, y: subView.bounds.size.height);
        context?.scaleBy(x: 1, y: -1);
        let snapshotImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage!
    }

    
    func saveToCamera(){
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
    func initSubView(_ targetView:UIView){
        var width:CGFloat = 0.0
        var height:CGFloat = 0.0
        if (ratio>1){
            //if horizontal
            width = initHorizontalWidth
            if(width/ratio < minSignatureSize){
                newView = Signature(frame: CGRect.init(x: targetView.bounds.size.width/2, y: targetView.bounds.size.height/2, width: minSignatureSize*ratio, height:minSignatureSize ))
            }else{
                newView = Signature(frame: CGRect.init(x: targetView.bounds.size.width/2, y: targetView.bounds.size.height/2, width: width, height:width/ratio ))
            }
            
        }else{
            //if vertical
            height = initVerticalHeight
            if height*ratio < minSignatureSize{
                newView = Signature(frame: CGRect.init(x: targetView.bounds.size.width/2, y: targetView.bounds.size.height/2, width: minSignatureSize, height:minSignatureSize/ratio ))
            }else{
                newView = Signature(frame: CGRect.init(x: targetView.bounds.size.width/2, y: targetView.bounds.size.height/2, width: height*ratio, height:height ))
            }
        }
        newView.tag = 100
    }
    
    
    
    func loadPDFifExist(){
        webView = UIWebView(frame: CGRect(x: formImageView.bounds.origin.x,
                                          y: formImageView.bounds.origin.y,
                                          width: formImageView.bounds.width,
                                          height: formImageView.bounds.height))
        webView.scalesPageToFit = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.delegate = self
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        guard let dirPath = paths.first else {
            return
        }

        let pdfLocation = self.trimImageName(imageName!) + ".pdf"
        let pdfPath = "\(dirPath)/MyAppImages/\(pdfLocation)"
        var objcBool:ObjCBool = false
        let isExist = FileManager.default.fileExists(atPath: pdfPath, isDirectory: &objcBool)
        if isExist{
            do {
                let pdfPath = "\(dirPath)/MyAppImages/\(pdfLocation)"
                let targetURL = NSURL(string: pdfPath)!
                
                let request = NSURLRequest(url: targetURL as URL)
                //let pdf: CGPDFDocument? = CGPDFDocument(targetURL)
                formImageView.image = nil
                webView.loadRequest(request as URLRequest)
                formImageView.addSubview(webView)
            } catch let error as NSError {
                print("CANNOT DELETE PDF")
                print(error.debugDescription)
            }
        }
    }
    
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
    
    // Trim ".png" off ImageName
    func trimImageName (_ str: String) -> String{
        let start = str.index(str.startIndex, offsetBy: 0)
        let end = str.index(str.endIndex, offsetBy: -4)
        let range = start..<end
        
        return str.substring(with: range)
    }
    
    // get document directory
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

extension UIPrintPageRenderer {
    func printToPDF() -> NSData {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, self.paperRect, nil)
        self.prepare(forDrawingPages: NSMakeRange(0, self.numberOfPages))
        let bounds = UIGraphicsGetPDFContextBounds()
        for i in 0..<self.numberOfPages {
            UIGraphicsBeginPDFPage();
            self.drawPage(at: i, in: bounds)
        }
        UIGraphicsEndPDFContext();
        return pdfData;
    }
}
