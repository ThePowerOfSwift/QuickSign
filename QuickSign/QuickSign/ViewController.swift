//
//  ViewController.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,
                        UITableViewDataSource,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate {

    var imagePicker:UIImagePickerController?=UIImagePickerController()
    var images:[UIImage]!
    var imagesDirectoryPath:String!
    var titles:[String]!
    

    @IBOutlet weak var myTableView: UITableView!
    
    /*-----------------------------------------
     *           Override Functions
     *----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Quick Sign"
        imagePicker?.delegate = self
        createDirectory()
        refreshTable()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.refreshTable),
                                               name:NSNotification.Name(rawValue: "Load Table"),
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //force portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if (segue.identifier == "showForm") {
            let vc        = segue.destination as! SingleFormView
            let indexPath = myTableView.indexPathForSelectedRow
            let rowNum    = indexPath!.row
            let image : UIImage = images[rowNum]
            
            vc.destinationMessage = "Row " + String(rowNum)
            vc.imageName = titles[rowNum]
            vc.image = image
        }
    }
    
    /*-----------------------------------------
     *           Button Functions
     *----------------------------------------*/
    
    @IBAction func AccessCameraRoll(_ sender: Any) {
        openMyGallary()
    }
    
    @IBAction func enterUrl(_ sender: Any) {
        self.getUrl()
    }
    
    /*-----------------------------------------
     *           Helper Functions
     *----------------------------------------*/
    
    func openMyGallary()
    {
        imagePicker!.allowsEditing = false
        imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker!, animated: true, completion: nil)
    }
    
    func getUrl() {
        let ac = UIAlertController(title: "Enter Form URL", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
            let answer = ac.textFields![0]

            print(answer.text!)
            let myURL = URL(string: answer.text!)
            //let urlRequest = NSURLRequest(url: myURL!)
           // let fileName = myURL?.lastPathComponent
            do {
                let pdfData = try NSData(contentsOf: myURL!, options: NSData.ReadingOptions())
                let image = self.drawImagefromURL(url: myURL!)
                let imageData: NSData = UIImagePNGRepresentation(image!)! as NSData
                let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                let documentDirectorPath:String = paths[0]
                let folderPath = documentDirectorPath.appendingFormat("/MyAppImages")
                var fileNameAsDate = NSDate().description
                fileNameAsDate = fileNameAsDate.replacingOccurrences(of: " ", with: "")
                let pdfFilePath = folderPath.appending("/" + fileNameAsDate + ".pdf")
                let imageFilePath = folderPath.appending("/" + fileNameAsDate + ".png")

                FileManager.default.createFile(
                    atPath: pdfFilePath,
                    contents: pdfData as Data,
                    attributes:nil
                )
                FileManager.default.createFile(
                    atPath: imageFilePath,
                    contents: imageData as Data,
                    attributes:nil
                )

                print("file created")
                self.refreshTable()

            } catch {
                print("ERROR: pdf file not created")
                print(error)
            }
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }

    func drawImagefromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height);
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0);
            
            ctx.cgContext.drawPDFPage(page);
        }
        
        return img
    }
    
    func createDirectory(){
        images = []
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectorPath:String = paths[0]
        imagesDirectoryPath = documentDirectorPath.appendingFormat("/MyAppImages")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with given path doesn't exist, create it
        if isExist == false{
            do{
                try FileManager.default.createDirectory(atPath: imagesDirectoryPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                print("Something went wrong while creating a new folder")
            }
        }
        print(imagesDirectoryPath)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            // Save image to Document directory
            var imagePath = NSDate().description
            imagePath = imagePath.replacingOccurrences(of: " ", with: "")
            print("image path")
            print(imagePath)
            imagePath = imagesDirectoryPath.appending("/\(imagePath).png")
            let data = UIImagePNGRepresentation(pickedImage)
            FileManager.default.createFile(
                atPath: imagePath,
                contents: data,
                attributes:nil
            )
            
            dismiss(animated: true) { () -> Void in
                self.refreshTable()
            }
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    
    func refreshTable(){
        do{
            images.removeAll()
            titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            
            for image in titles{
                if image.contains(".png"){
                    let data = FileManager.default.contents(atPath: imagesDirectoryPath.appending("/\(image)"))
                    let image = UIImage(data: data!)
                    //add subtitle text
                    images.append(image!)
                }
            }
            myTableView.reloadData()
        }catch{
            print("Error")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CustomTableViewCell = CustomTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "myCell")
        
        //fix line separator
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.imageView?.image = images[indexPath.row]
        cell.textLabel?.text = "Form #" + String(indexPath.row + 1)
        
        //add date as subtitle
        let index = titles[indexPath.row].index(titles[indexPath.row].startIndex, offsetBy: 10)
        cell.detailTextLabel?.text = titles[indexPath.row].substring(to: index)

        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showForm", sender: indexPath.row)
    }
    

}





