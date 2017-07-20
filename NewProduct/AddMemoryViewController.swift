//
//  AddMemoryViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-07-19.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Firebase

class AddMemoryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var btnAddVideo: UIButton!
    @IBOutlet weak var tbTitle: UITextField!
    @IBOutlet weak var DatePick: UIDatePicker!
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    
    var vidURL: URL!
    let dataRef = FIRDatabase.database().reference()
    let loggedUser = FIRAuth.auth()?.currentUser
 
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addVideo(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        self.present(imagePicker, animated: true, completion: nil)
        

        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL{
            
            
            vidURL = videoURL as URL!
            
            if let thumbnailImage = self.thumbNail(fileURL: videoURL)
            {
                self.btnAddVideo.setImage(thumbnailImage, for: .normal)
            }
           
            
        }
    
        dismiss(animated: true, completion: nil)
    }
    
    func handleVideoSelectedForUrl(url: NSURL){
        
        self.Loader.startAnimating()
        
        
        let filename = "default.mov"
        let uploadTask = FIRStorage.storage().reference().child(filename).putFile(url as URL, metadata: nil, completion: { (metadata, error) in
            
            if error != nil{
                let alertContoller = UIAlertController(title: "Error", message: error as? String, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
                self.btnComplete.isHidden = false
                self.Loader.stopAnimating()
                return
            }
            
            if let storageUrl = metadata?.downloadURL()?.absoluteString{
                //self.vidURL = url as URL!
                
                let dateFormatter = DateFormatter()
                
                dateFormatter.dateStyle = DateFormatter.Style.short
                dateFormatter.timeStyle = DateFormatter.Style.short
                
                let strDate = dateFormatter.string(from: self.DatePick.date)
                
                let memory: [String : AnyObject] = ["video": storageUrl as AnyObject,
                                                         "Title": self.tbTitle.text as AnyObject,
                                                         "Date": strDate as AnyObject]
                
            self.dataRef.child("users").child(self.loggedUser!.uid).child("Memories").childByAutoId().setValue(memory)
                
                self.Loader.stopAnimating()
                
                self.dismiss(animated: true, completion: nil)
                
                
                //about to pass data and add text stuff
            }
            
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount as Any)
        }

    }
    
    func thumbNail(fileURL: NSURL) -> UIImage?{
        
        let asset = AVAsset(url: fileURL as URL)
        let imageGen = AVAssetImageGenerator(asset: asset)
        
        
        do{
            
            let thumbnailImage = try imageGen.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailImage)
            
        }catch let err{
            print(err)
        }
        
        
        return nil
        
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.btnComplete.isHidden = false
    }
    
    @IBAction func Dismiss(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.tbTitle.resignFirstResponder()
        
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    @IBAction func Add(_ sender: Any) {
        
        if vidURL != nil && tbTitle.text != nil{
            
            self.btnComplete.isHidden = true
        handleVideoSelectedForUrl(url: vidURL! as NSURL)
        
            
        }
        else{
            let alertContoller = UIAlertController(title: "Error", message: "Fill out the required fields", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated: true, completion: nil)
        }
    }
    

}
