//
//  ViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-03-10.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

                                            //CODE FOR MAIN PROFILE

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgMain: UIImageView!
    //@IBOutlet weak var Logout: UIButton!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var longpress: UILongPressGestureRecognizer!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet var longLabel: UILongPressGestureRecognizer!
    @IBOutlet weak var tbAbout: UITextField!
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet weak var lblEmail: UILabel!
    
    //declarations for about section
    @IBOutlet weak var lblLoc: UILabel!
    @IBOutlet weak var lblBirth: UILabel!
    @IBOutlet weak var lblGend: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
   
    //MARK: Declaration of variables
    
    let NameRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    
    var upload = false
    
    var ableToSwitch = false
    var loc = ""
    var birth = ""
    var gend = ""
    var skills = ""
    
    var email:String!
    
    var imagePicker = UIImagePickerController()
    
    var state = false
    
    var artistCreate = false
    
    let user = FIRAuth.auth()?.currentUser
    
    //I was being lazy and made variables for these references
   let NameLoad = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Name")
    let aboutLoad = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("About")
    
    let manager = CLLocationManager()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        
        
        lblName.isUserInteractionEnabled = true
        btnSave.layer.mask?.cornerRadius = 5

        
            //if user is logged out
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            LogoutSeq()
            //this removes every saved thing
            
            
        }
        
        //set profile qualities
        setupProfile()
        
        
        //allow the profile pic to be clicked
        self.imgMain.isUserInteractionEnabled = true
       
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        NameRef.child("users").child(self.user!.uid).child("location(LL)").setValue("\(location.coordinate.latitude),\(location.coordinate.longitude)")
       // print(manager.location!)
        if manager.location != nil
        {
            manager.stopUpdatingLocation()
        }
    
    }


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
                                                    //SETTING UP THE PROFILE
    func setupProfile(){
        
//        self.NameRef.child("artistProfiles").child(self.user!.uid).child("token").observe(.value){
//            (snap: FIRDataSnapshot) in
            if UserDefaults.standard.bool(forKey: "artistCreate") == true
            {
                self.artistCreate = true
            }
            else
            {
                self.artistCreate = false
            }
            
        
    
        imgMain.layer.cornerRadius = 4
        imgMain.clipsToBounds = true
        
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true

        self.Loader.startAnimating()
        
        
        //loading image from database into view. Found this online. Not as efficient as I would have liked but it works

        if UserDefaults.standard.object(forKey: "savedImage") != nil
        {
            let imgdata2 = UserDefaults.standard.object(forKey: "savedImage") as! NSData
            imgMain.image = UIImage(data: imgdata2 as Data)
            self.Loader.stopAnimating()
        }
        else
        {
            
                        let uid = FIRAuth.auth()?.currentUser?.uid
                        NameRef.child("users").child(uid!).observeSingleEvent(of: .value, with: {  (snapshot) in
                            if let dict = snapshot.value as? [String: AnyObject]
                            {
            
                            if let profileImageURL = dict["pic"] as? String
                            {
            
            
                                let url = URL(string: profileImageURL)
                                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                                    if error != nil{
                                       // print(error!)
                                        return
                                    }
                                    DispatchQueue.main.async {
            
                                        if data == nil
                                        {
                                            self.Loader.stopAnimating()
                                        }
                                        else
                                        {
                                            self.imgMain?.image = UIImage(data: data!)
                                            UserDefaults.standard.set(data!, forKey: "savedImage")
                                            self.ableToSwitch = true
                                            self.Loader.stopAnimating()
                                        }
                                        
            
                                    }
                                    
                                }).resume()
                                
                            }
                            else{
                                    self.Loader.stopAnimating()
                                }
                            }
                    })
            
        
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
                                            //MARK: Grabbing Data
        NameLoad.observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblName.text = snap.value as? String
            
        }

        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Location").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp1 = snap.value as? String{
                self.loc = temp1
                self.lblLoc.text = "Location: \(temp1)"
            }
            
        }
        
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Email").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp1 = snap.value as? String{
                self.email = temp1
                self.lblEmail.text = temp1
            }
            
        }
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Birthday").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp2 = snap.value as? String{
                self.birth = temp2
                self.lblBirth.text = "Birthday: \(temp2)"
            }
        }
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Gender").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp3 = snap.value as? String{
                self.gend = temp3
                self.lblGend.text = "Gender: \(temp3)"
            }
            
        }
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Skills").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp4 = snap.value as? String{
                self.skills = temp4
                self.lblID.text = "Skills: \(temp4)"
            }
        }
    
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    //MARK: Image Pickers
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //btnSave.isHidden = false

        //Seeting the image equal to the profile picture. If the image was edited (cropped) it will upload that instead
        var selectedImage:UIImage?
        
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            selectedImage = originalImage
        }
        
        if let selectedImage2 = selectedImage
        {
//            Loader.startAnimating()
            imgMain.image = selectedImage2
            upload = true
            saveChange()
//            Loader.stopAnimating()
            
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //if persons presses cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
                                                    //SAVING CHANGES
    func saveChange(){
        
        Loader.startAnimating()
        let imageName =  NSUUID().uuidString
        let storedImage = storageRef.child("imgMain").child(imageName)
        
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        let task = Task(context: context) // Link Task & Context
//        //task.name = taskTextField.text!
//        
//        // Save the data to coredata
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        
        
        
        //also found this online
        if let uploadData = UIImagePNGRepresentation(self.imgMain.image!)
        {
           
            
            
            storedImage.put(uploadData, metadata: nil, completion: { ( metadata, error) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    return
                }
                storedImage.downloadURL(completion: { (url,error) in
                    if error != nil
                    {
                        let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                        alertContoller.addAction(defaultAction)
                        self.present(alertContoller, animated: true, completion: nil)
                        
                        return
                    }
                    if let urlText = url?.absoluteString{
                        
                        
                        
                        
                        self.NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error,ref) in
                            if error != nil
                            {
                                let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertContoller.addAction(defaultAction)
                                self.present(alertContoller, animated: true, completion: nil)
                            
                                return
                            }
                            self.Loader.stopAnimating()
                            self.ableToSwitch = true
                            self.btnSave.isHidden = true
                            let imgData = UIImagePNGRepresentation(self.imgMain.image!)! as NSData
                            UserDefaults.standard.set(imgData, forKey: "savedImage")
                        })
                        if self.artistCreate == true
                        {
                        self.NameRef.child("artistProfiles").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error,ref) in
                            if error != nil
                            {
                                let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                                
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                alertContoller.addAction(defaultAction)
                                self.present(alertContoller, animated: true, completion: nil)
                                
                                return
                            }
                            self.Loader.stopAnimating()
                            self.ableToSwitch = true
                            self.btnSave.isHidden = true
                        })
                        }
                    }
                    })
                })
            }
    }

//what happens when logout is clicked
    func LogoutSeq(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "login")
        
        if UserDefaults.standard.object(forKey: "savedImage") != nil{
        
        UserDefaults.standard.removeObject(forKey: "savedImage")
        }
        UserDefaults.standard.removeObject(forKey: "artistOn")
        UserDefaults.standard.removeObject(forKey: "artistCreate")
        
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        
        // Now remove the object for the keys starting with "ProfilePic"
        
        for key in allKeys{
            
            if key.hasPrefix("ProfilePic"){
                UserDefaults.standard.removeObject(forKey: key)
            }
            
        }

        
        self.present(loginVC, animated: true, completion: nil)
        
        }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    //When user taps profile picture
    @IBAction func Tapped(_ sender: UITapGestureRecognizer) {
        
        //this method opens a little menu at the bottom with the options; View Picture, Photos and Camera
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        let myActionSheet = UIAlertController(title: "Profile Picture", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let viewPicture = UIAlertAction(title: "View Picture", style: UIAlertActionStyle.default) { (action) in
            //Put code for what happens when the button is clicked
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            
            
            newImageView.frame = self.view.frame
            
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
            
            newImageView.addGestureRecognizer(tap)
            self.view.addSubview(newImageView)
            
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
            {
                
                //Not sure why i have to set the imagepickers delegate to self. Thats the only way it worked tho
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
                self.imagePicker.allowsEditing = true
                self.state = false
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }
        
        let camera = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                
                //This was a pain in the ass to get to work. In the in GoogleService-Info.plist you HAVE to add the camera permission (for future projects obvi)
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                self.imagePicker.allowsEditing = true
                self.state = false
                self.present(self.imagePicker, animated: true, completion: nil)
                
            }
        }
        
        
        myActionSheet.addAction(viewPicture)
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    // This func just dismisses the view when the user tappen "View Picture"
    func dismissFullScreenImage(_sender:UITapGestureRecognizer){
        _sender.view?.removeFromSuperview()
    }
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

                        //long press for cover photo (Not being used)
    @IBAction func LongPress(_ sender: UILongPressGestureRecognizer) {
}

    @IBAction func longPressLabel(_ sender: UILongPressGestureRecognizer) {
        //When the label with the name stored in it is long pressed, this occurs
        
        //Allows me to edit the name in the database. I don't like the look of it but it will suffice for now
        let alertController = UIAlertController(title: "Edit Name", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            if firstTextField.text == ""
            {
                
            }
            else
            {
            //print("firstName \(firstTextField.text)")
            
            self.lblName.text = firstTextField.text
            
           // self.btnSave.isHidden = false
            }
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.Loader.stopAnimating()
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter First and Last Name"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tbAbout.resignFirstResponder()
        return true
    }
   
    @IBAction func tbEditBeing(_ sender: Any) {
       // btnSave.isHidden = false
    }
    

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func editClick(_ sender: Any) {
        
        
        

        
       // This brings up the dialogue for changing the about field
        let alertController = UIAlertController(title: "Edit Information", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            
            
            
            let firstTextField = alertController.textFields![0] as UITextField
             firstTextField.placeholder = "Please enter a location (City/State/Country)"
            
            if firstTextField.text != ""
            {
               
            
                //print("firstName \(firstTextField.text)")
                if let temp1 = firstTextField.text{
                self.lblLoc.text = "Location: \(temp1)"
                self.loc = temp1
                //self.btnSave.isHidden = false
                self.NameRef.child("users").child(self.user!.uid).child("Location").setValue(temp1)
                    print(UserDefaults.standard.bool(forKey: "artistCreate"))
                    print(self.artistCreate)
                    print(UserDefaults.standard.bool(forKey: "artistOn"))
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Location").setValue(temp1)
                    }
                    
                }
            }
            
            let secondTextField = alertController.textFields![1] as UITextField
            secondTextField.placeholder = "Please enter a birthday(dd/mm/yy)"
            if secondTextField.text == ""
            {
                
            }
            else
            {
                //print("firstName \(firstTextField.text)")
                if let temp2 = secondTextField.text{
                self.lblBirth.text = "Birthday: \(temp2)"
                self.birth = temp2
                //self.btnSave.isHidden = false
                    self.NameRef.child("users").child(self.user!.uid).child("Birthday").setValue(temp2)
                    
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Birthday").setValue(temp2)
                    }
                }
            }
            
            let thirdTextField = alertController.textFields![2] as UITextField
            thirdTextField.placeholder = "Please enter a gender"
            if thirdTextField.text == ""
            {
                
            }
            else
            {
                if let temp3 = thirdTextField.text{
                
                self.lblGend.text = "Gender: \(temp3)"
                self.gend = temp3
                //self.btnSave.isHidden = false
                    self.NameRef.child("users").child(self.user!.uid).child("Gender").setValue(temp3)
                    
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Gender").setValue(temp3)
                    }
                }
            }
            
            let fourthTextField = alertController.textFields![3] as UITextField
            fourthTextField.placeholder = "Please enter some skills"
            if fourthTextField.text == ""
            {
                
            }
            else
            {
                //print("firstName \(firstTextField.text)")
                if let temp4 = fourthTextField.text{
                self.lblID.text = "Skills: \(temp4)"
                self.skills = temp4
                //self.btnSave.isHidden = false
                    self.NameRef.child("users").child(self.user!.uid).child("Skills").setValue(temp4)
                    
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Skills").setValue(temp4)
                    }
                }
            }
            
            
            
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.Loader.stopAnimating()
            
        })
        
        alertController.addTextField { (firstTextField : UITextField!) -> Void in
            
            if (self.lblLoc.text == "Location: Not Declared" || self.lblLoc.text == "Location:")
            {
            firstTextField.placeholder = "Please enter a location (City/State/Country)"
            }
            else
            {
                firstTextField.text = self.loc
            }
           
        }
        alertController.addTextField { (secondTextField : UITextField!) -> Void in
            if (self.lblBirth.text == "Birthday: Not Declared" || self.lblBirth.text == "Birthday:")
            {
                secondTextField.placeholder = "Please enter a birthday (dd/mm/yyyy)"
            }
            else
            {
                secondTextField.text = self.birth
            }
            
        }
        alertController.addTextField { (thirdTextField : UITextField!) -> Void in
            if (self.lblGend.text == "Gender: Not Declared" || self.lblGend.text == "Gender:")
            {
                thirdTextField.placeholder = "Please enter a gender"
            }
            else
            {
                thirdTextField.text = self.gend
            }
            
        }
        alertController.addTextField { (fourthTextField : UITextField!) -> Void in
            if (self.lblID.text == "Skills: Not Declared" || self.lblID.text == "Skills:")
            {
                fourthTextField.placeholder = "Please enter your skills (necessary for artist account)"
            }
            else
            {
                fourthTextField.text = self.skills
            }
            
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
  
    @IBAction func btnMoreAction(_ sender: Any) {
        

        
        let myActionSheet = UIAlertController(title: "Options", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let Logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (action) in
            
            
            self.setupProfile()
            try! FIRAuth.auth()?.signOut()
            self.LogoutSeq()
            
        }
        
        let sentInquires = UIAlertAction(title: "Sent Inquires", style: UIAlertActionStyle.default) { (action) in
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "sentInquire") as! sentInquireViewController
            
            self.present(myVC, animated: true)
            
            
        }
        
//        let createArtist = UIAlertAction(title: alertTitle, style: UIAlertActionStyle.default) { (action) in
//            
//            
//                
//                if self.artistCreate == true
//                {
//                    
//
//
//                }
//                else{
//                    if self.skills == ""
//                    {
//                        let alertContoller = UIAlertController(title: "Oops!", message: "Add a set of skills to procede", preferredStyle: .alert)
//                        
//                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                        alertContoller.addAction(defaultAction)
//                        self.present(alertContoller, animated: true)
//                    }
//                    else{
//                    
//                    
//                    self.NameRef.child("artistProfiles").child(self.user!.uid).child("Name").setValue(self.lblName.text)
//                    
//                    self.NameRef.child("artistProfiles").child(self.user!.uid).child("token").setValue(self.user!.uid)
//                    
//                   
//                    self.NameRef.child("artistProfiles").child(self.user!.uid).child("skills").setValue(self.skills)
//                        
//                    self.NameRef.child("artistProfiles").child(self.user!.uid).child("Email").setValue(self.email)
//                    
//                    self.NameRef.child("users").child(self.user!.uid).child("pic").observe(.value){
//                        (snap: FIRDataSnapshot) in
//                        
//                        if snap.exists() == true
//                        {
//                            self.NameRef.child("artistProfiles").child(self.user!.uid).child("pic").setValue(snap.value as! String)
//                        }
//                        else{
//                            self.NameRef.child("artistProfiles").child(self.user!.uid).child("pic").setValue("default.ca")
//                        }
//                        let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController
//                        
//                        myVC.token = self.user!.uid
//                        
//                        self.present(myVC, animated: true)
//                    }
//                    
//                }
//            }
//            
        
            

            
            
            
            
            
//        }
        
        
        
        //myActionSheet.addAction(createArtist)
        myActionSheet.addAction(sentInquires)
        myActionSheet.addAction(Logout)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}
