//
//  Profile.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-03-12.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class Profile: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
  
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var imgLoader: UIActivityIndicatorView!
    
    
    
    var loggedInUser : AnyObject?
    var databaseRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        imgLoader.stopAnimating()
        
        self.loggedInUser = FIRAuth.auth()?.currentUser
    self.databaseRef.child("user_profiles").child(self.loggedInUser!.uid).observeSingleEvent(of: .value, with: { (snapshot:FIRDataSnapshot) in
        
        let snapshot = snapshot.value as! [String: AnyObject]
        
        self.name.text = snapshot["name"] as? String
        
        
        
        if (snapshot["profile_pic"] !== nil)
        {
            let databaseProfilePic = snapshot["profile_pic"] as! String
            
            let data = try? Data(contentsOf: URL(string: databaseProfilePic)!)
            
            self.setProfilePicture(imageView: self.profilePicture, imageToSet: UIImage(data:data!)!)
        }
            
            
            
        })
        
    
        
        
        
    }
  
    //function to show login viewController (for logout button)
    func ShowMain(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(loginVC, animated: true, completion: nil)
        
    }
    
    //sets the actual picture
    internal func setProfilePicture(imageView:UIImageView, imageToSet: UIImage)
    {
        imageView.layer.cornerRadius = 10
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.masksToBounds = true
        imageView.image = imageToSet
        
    }
    
//When the image is clicked
    @IBAction func Clicker(_ sender: Any) {
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let viewPicture = UIAlertAction(title: "View Picture", style: UIAlertActionStyle.default) { (action) in
            
            let imageView = UIImageView()
            let newImageView = UIImageView(image: imageView.image)
            
            newImageView.frame = self.view.frame
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
      
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
            {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }
        
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
        
    }
    
    func dismissFullScreenImage(_ sender: UITapGestureRecognizer){
        sender.view?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?){
        
        self.imgLoader.startAnimating()
        setProfilePicture(imageView: self.profilePicture, imageToSet: image)
        
        if let imageData: NSData = UIImagePNGRepresentation(self.profilePicture.image!)! as NSData?
        {
            let profilePicStorageRef = storageRef.child("user_profile/\(self.loggedInUser!.uid)/profile_pic")
            _ = profilePicStorageRef.put(imageData as Data, metadata: nil)
            {metadata,error in
                if error == nil
                {
                    let downloadURL = metadata!.downloadURL()
                    
                self.databaseRef.child("user").child(self.loggedInUser!.uid).child("profile_pic").setValue(downloadURL!.absoluteString)
                }
                else
                {
                    print(error?.localizedDescription as Any)
                }
                self.imgLoader.stopAnimating()
        }
        
        }
       self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Logout(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
        
        LogoutSeq()
    }
    
    
    func LogoutSeq(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "login")
        self.present(loginVC, animated: true, completion: nil)
        
    }
    
    
    
}
