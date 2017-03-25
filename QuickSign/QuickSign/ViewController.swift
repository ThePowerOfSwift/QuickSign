//
//  ViewController.swift
//  QuickSign
//
//  Created by mac on 2017-03-19.
//  Copyright © 2017 max. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,
    UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker:UIImagePickerController?=UIImagePickerController()
    var images:[UIImage]!
    var imagesDirectoryPath:String!
    var titles:[String]!
    
    @IBAction func AccessCameraRoll(_ sender: Any) {
        openMyGallary()
    }
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //force portrait
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        imagePicker?.delegate = self
        createDirectory()
        refreshTable()
        self.title = "Quick Sign"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //force landscape
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    func openMyGallary()
    {
        imagePicker!.allowsEditing = false
        imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(imagePicker!, animated: true, completion: nil)
    }
    
    func createDirectory(){
        images = []
        
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        // Get the Document directory path
        let documentDirectorPath:String = paths[0]
        // Create a new path for the new images folder
        imagesDirectoryPath = documentDirectorPath.appendingFormat("/MyAppImages")
        var objcBool:ObjCBool = true
        let isExist = FileManager.default.fileExists(atPath: imagesDirectoryPath, isDirectory: &objcBool)
        // If the folder with the given path doesn't exist already, create it
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
        
        //display in imageView
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            /*
             //show last open image in imageView
             myImageView.contentMode = .scaleAspectFit
             myImageView.image = pickedImage
             */
            
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
        
        //leave the default stuff here alone
        dismiss(animated: true, completion: nil)
    }
    
    
    func refreshTable(){
        do{
            images.removeAll()
            titles = try FileManager.default.contentsOfDirectory(atPath: imagesDirectoryPath)
            
            for image in titles{
                let data = FileManager.default.contents(atPath: imagesDirectoryPath.appending("/\(image)"))
                let image = UIImage(data: data!)
                //add subtitle text
                images.append(image!)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if (segue.identifier == "showForm") {
            // Create an instance of the next view controller.
            let vc        = segue.destination as! SingleFormView
            let indexPath = myTableView.indexPathForSelectedRow
            let rowNum    = indexPath!.row
            let image : UIImage = images[rowNum]

            // Pass the row number and label value to the destination.
            vc.destinationMessage = "Row " + String(rowNum)
            vc.image = image
            // Debug output.
            print("Going to view 2.")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showForm", sender: indexPath.row)
    }
    

}





