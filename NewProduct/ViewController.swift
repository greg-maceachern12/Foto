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
import Photos
import SDWebImage
import AVKit
import AVFoundation


struct memoryStruct{
    let videoLink: NSURL!
    let title: String!
    let date: String!
    let acccessCode: String!
    let artist: String!
}


class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UIBarPositioningDelegate {
    

    @IBOutlet weak var HomeTitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgMain: UIImageView!
    //@IBOutlet weak var Logout: UIButton!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBOutlet var longpress: UILongPressGestureRecognizer!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var tbAbout: UITextField!
    @IBOutlet weak var tabBar: UITabBarItem!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var homeTab: UITableView!
    
    //declarations for about section
    @IBOutlet weak var lblLoc: UILabel!
    @IBOutlet weak var lblAge: UILabel!
    @IBOutlet weak var lblGend: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    
     var overlay : UIView?
     var overlayAct : UIActivityIndicatorView?
     var pickerGend = UIPickerView()
    
     let genders = ["Male", "Female", "Other"]
   
    //MARK: Declaration of variables
    
    let NameRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    let loggedUser = FIRAuth.auth()?.currentUser
    
    var upload = false
    
    var memories = [memoryStruct]()
    
    var ableToSwitch = false
    var loc: String!
  
    
    var email:String!
    
    var imagePicker = UIImagePickerController()
    
    var state = false
    
    var artistCreate = false
    
    let user = FIRAuth.auth()?.currentUser


    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creates a loading view that will dissapear once the data has loaded
        overlay = UIView(frame: view.frame)
        
        overlayAct = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 17, y: self.view.frame.height/2 - 7 , width: 35, height: 35))
        overlay!.backgroundColor = UIColor.black
        overlay!.alpha = 0.8
        overlayAct?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        view.addSubview(overlay!)
        view.addSubview(overlayAct!)
        overlayAct?.startAnimating()
        
        lblName.isUserInteractionEnabled = true
        btnSave.layer.mask?.cornerRadius = 5

        
            //if user is logged out
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            LogoutSeq()
            //this removes all of the cached information
            
            
        }
        
        
        self.HomeTitle.text = "Loading Data"
        
        //set profile qualities
        setupProfile()
        self.NameRef.child("users").child(self.loggedUser!.uid).child("Memories").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
            //
            if snapshot.exists() == true{
                let snapshotValueName = snapshot.value as? NSDictionary
                let Title = snapshotValueName?["Title"] as? String
                
                let Artist = snapshotValueName?["Artist"] as? String
                
                
                let dateFIR = snapshotValueName?["Date"] as? String
                
                let code = snapshotValueName?["code"] as? String
                
                let snapshotValuePic = snapshot.value as? NSDictionary
                var url = NSURL()
                if let pic = snapshotValuePic?["video"] as? String
                {
                    url = NSURL(string:pic)!
                    
                }
                else{
                    url = NSURL(string:"")!
                    
                }
                
                self.memories.insert(memoryStruct(videoLink: url, title: Title, date: dateFIR, acccessCode: code, artist: Artist), at: 0)
                print(self.memories)
                
                
                
                
            }
            else
            {
                let alertContoller = UIAlertController(title: "Oops!", message: "No Memories!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertContoller.addAction(defaultAction)
                
                self.present(alertContoller, animated:true, completion: nil)
            }
            
            
            self.homeTab.reloadData()
            
            
        })

        
        
        //allow the profile pic to be clicked
        self.imgMain.isUserInteractionEnabled = true
        self.HomeTitle.text = "Home"

      
        
        
        
//       
    }
    
   
    


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
                                                    //SETTING UP THE PROFILE
    func setupProfile(){
        
        //if the current user is also an artist, set artist create to true. This variable allows the information of this page to be saved in the artistprofile on firebase.
            if UserDefaults.standard.bool(forKey: "artistCreate") == true
            {
                self.artistCreate = true
                print(artistCreate)
            }
            else
            {
                self.artistCreate = false
                print(artistCreate)
            }
            
        
    
        imgMain.layer.cornerRadius = 4
        imgMain.clipsToBounds = true
        
        btnSave.layer.cornerRadius = 5
        btnSave.clipsToBounds = true
        
        

        self.Loader.startAnimating()
        
        
        //loading image from database into view
        
        //if there is no image saved in the cache, grab it from the database

        if UserDefaults.standard.object(forKey: "savedImage") != nil
        {
            let imgdata2 = UserDefaults.standard.object(forKey: "savedImage") as! NSData
            imgMain.image = UIImage(data: imgdata2 as Data)
            self.Loader.stopAnimating()
            overlay?.removeFromSuperview()
            overlayAct?.removeFromSuperview()
           
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
            
                                        if data == nil || profileImageURL == "default.ca"
                                        {
                                            self.Loader.stopAnimating()
                                            self.overlay?.removeFromSuperview()
                                            self.overlayAct?.removeFromSuperview()
                                        }
                                        else
                                        {
                                            self.imgMain?.image = UIImage(data: data!)
                                            UserDefaults.standard.set(data!, forKey: "savedImage")
                                            self.ableToSwitch = true
                                            self.Loader.stopAnimating()
                                            self.overlay?.removeFromSuperview()
                                            self.overlayAct?.removeFromSuperview()
                                        }
                                        
            
                                    }
                                    
                                }).resume()
                                
                            }
                            else{
                                    self.Loader.stopAnimating()
                                self.overlay?.removeFromSuperview()
                                self.overlayAct?.removeFromSuperview()
                                }
                            }
                    })
            
            
        
        }
        
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        
                                            //MARK: Grabbing Data
        FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Name").observe(.value){
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
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Age").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp2 = snap.value as? Int{
                
                self.lblAge.text = "Age: \(temp2)"
            }
        }
        NameRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Gender").observe(.value){
            (snap: FIRDataSnapshot) in
            if let temp3 = snap.value as? String{
              
                self.lblGend.text = "Gender: \(temp3)"
            }
            
        }
       
    
}
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    

//what happens when logout is clicked
    func LogoutSeq(){
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC: UIViewController = storyboard.instantiateViewController(withIdentifier: "login")
        
        //delete all the saved cache information
        
        if UserDefaults.standard.object(forKey: "savedImage") != nil{
        
        UserDefaults.standard.removeObject(forKey: "savedImage")
        }
        UserDefaults.standard.removeObject(forKey: "artistOn")
        UserDefaults.standard.removeObject(forKey: "artistCreate")
        
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        
         //Now remove the object for the keys starting with "ProfilePic" (most of the pictures)
        
        for key in allKeys{

            if key.hasPrefix("Profile"){
                UserDefaults.standard.removeObject(forKey: key)
            }
            
        }


        
        self.present(loginVC, animated: true, completion: nil)
        
        }
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    //Mark: TableView Data
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //playing the selected video in the memories section
        let videoURL = memories[indexPath.row].videoLink
        let player = AVPlayer(url: videoURL! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        self.homeTab.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
            //What happens when Edit button is tapped

            
            self.NameRef.child("users").child(self.loggedUser!.uid).child("Memories").child(self.memories[indexPath.row].acccessCode).removeValue(completionBlock:  { (error,ref) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    
                    return
                }
                
                self.homeTab.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                self.memories.remove(at: indexPath.row)
                
                
                
                self.homeTab.reloadData()
                
                })
                
 

        }
        return [delete]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")

        print(self.memories[indexPath.row])
        
        let label1 = cell?.viewWithTag(1) as! UILabel
        label1.text = memories[indexPath.row].title
        
        let label2 = cell?.viewWithTag(2) as! UILabel
        label2.text = memories[indexPath.row].date
        
        let label3 = cell?.viewWithTag(5) as! UILabel
        label3.text = memories[indexPath.row].artist
        
        let Loader = cell?.viewWithTag(3) as! UIActivityIndicatorView
        
        
        let asset = AVAsset(url: memories[indexPath.row].videoLink! as URL)
        let imageGen = AVAssetImageGenerator(asset: asset)
        
        
        do{
            Loader.startAnimating()
            
            
            //if the thumbnails for the memories are saved in the cache, use those for the image in the table. If not, use the imagedata variable and set the image using that and save that in the cache
            if UserDefaults.standard.object(forKey: "ProfileVid\(indexPath.row)") == nil{
                
                let thumbnailImage = try imageGen.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
                
                let img4 = cell?.viewWithTag(4) as! UIImageView
                img4.image = UIImage(cgImage: thumbnailImage)
                let imgData2 = UIImagePNGRepresentation(img4.image!)! as NSData
                UserDefaults.standard.set(imgData2, forKey: "ProfileVid\(indexPath.row)")
                Loader.stopAnimating()
            }
            else{
                
                let img4 = cell?.viewWithTag(4) as! UIImageView
                
                let imgdata = UserDefaults.standard.object(forKey: "ProfileVid\(indexPath.row)") as! NSData
                
                img4.image = UIImage(data: imgdata as Data)
                
                Loader.stopAnimating()
                
            }

        }
        catch let err{
            print(err)
        }
  
        
        return cell!
        
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
        
            
            let imageView = sender.view as! UIImageView
            let newImageView = UIImageView(image: imageView.image)
            
            
            newImageView.frame = self.view.frame
            
            newImageView.backgroundColor = UIColor.black
            newImageView.contentMode = .scaleAspectFit
            
            newImageView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target:self,action:#selector(self.dismissFullScreenImage))
            
            newImageView.addGestureRecognizer(tap)
            
            newImageView.layer.opacity = 0
            self.view.addSubview(newImageView)
            
            UIView.animate(withDuration: 0.4, animations: {
                
                newImageView.layer.opacity = 1
                
            })
            
            
        }
        
        let photoGallery = UIAlertAction(title: "Photos", style: UIAlertActionStyle.default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
            {
             //opens the image picker
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
    @objc func dismissFullScreenImage(_sender:UITapGestureRecognizer){
        
       //makes the image fade and disappear
        UIView.animate(withDuration: 0.4, animations: {
            
            _sender.view?.layer.opacity = 0
            
        }, completion: { (finished: Bool) in
            _sender.view?.removeFromSuperview()
        })
       
    }
    //MARK: Image Pickers
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Setting the selected image equal to the profile picture. If the image was edited (cropped) it will upload that instead
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
            //save this image to the database
            imgMain.image = selectedImage2
            upload = true
            saveChange()
 
            
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
        
        
        //Uploading the selected image to the database
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
                        
                        //if the user is also an artist, upload this data to the artist profiles node in firebase
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
    

    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tbAbout.resignFirstResponder()
        return true
    }
   

    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    @IBAction func editClick(_ sender: Any) {

        //edit the usres information which will be saveed to the user profile as well as the artist profile if the variable "artistCreate" is set to true
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 150)
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 50))
        let text1 = UITextField(frame: CGRect(x: 75, y: 0, width: 175, height: 50))
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 40, width: 75, height: 50))
        let text2 = UITextField(frame: CGRect(x: 75, y: 40, width: 175, height: 50))
        //let pickerDate = UIDatePicker(frame: CGRect(x: 75, y: 50, width: 175, height: 100))
        
        let label3 = UILabel(frame: CGRect(x: 0, y: 80, width: 75, height: 50))
        pickerGend = UIPickerView(frame: CGRect(x: 75, y: 80, width: 175, height: 50))
     
       //pickerDate.datePickerMode = UIDatePickerMode.date
        
       
        pickerGend.dataSource = self
        pickerGend.delegate = self
   
        text1.font = UIFont(name: "Avenir Next", size: 13)
        text1.placeholder = "Enter Your Location"
        
        text2.font = UIFont(name: "Avenir Next", size: 13)
        text2.placeholder = "Enter Your Age"
        text2.keyboardType = UIKeyboardType.numberPad
        
        label1.font = UIFont(name: "Avenir Next", size: 13)
        label2.font = UIFont(name: "Avenir Next", size: 13)
        label3.font = UIFont(name: "Avenir Next", size: 13)
        
        label1.text = "Location:"
        label2.text = "Age:"
        label3.text = "Gender:"
        //pickerGender.dataSource = genders as? UIPickerViewDataSource
        
        vc.view.addSubview(text2)
        vc.view.addSubview(pickerGend)
        vc.view.addSubview(text1)
        vc.view.addSubview(label1)
        vc.view.addSubview(label2)
        vc.view.addSubview(label3)
        let editRadiusAlert = UIAlertController(title: "Edit Your Information", message: "", preferredStyle: UIAlertControllerStyle.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            
            
            if text1.text != ""
            {


                //print("firstName \(firstTextField.text)")
                if let temp1 = text1.text{
                self.lblLoc.text = "Location: \(temp1)"
                //self.loc = temp1
                //self.btnSave.isHidden = false
                self.NameRef.child("users").child(self.user!.uid).child("Location").setValue(temp1)
                   
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Location").setValue(temp1)
                    }
                    
                }
            }
            

            if text2.text == "" || text2.text == nil || Int(text2.text!) == nil
            {

            }
            else
            {
                //print("firstName \(firstTextField.text)")
                if let temp2 = text2.text{
                self.lblAge.text = "Age: \(temp2)"
                //self.birth = temp2
                //self.btnSave.isHidden = false
                    self.NameRef.child("users").child(self.user!.uid).child("Age").setValue(Int(temp2))

                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Age").setValue(Int(temp2))
                    }
                }
            }
            
            
            self.NameRef.child("users").child(self.user!.uid).child("Gender").setValue(self.loc)
            
            
            
            
        }))
    
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
 
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        loc = genders[row]
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

            return 3
        
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "Avenir Next", size: 15)
        
        // where data is an Array of String
        label.text = genders[row]
        
        return label
    }
 
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    @IBAction func btnMoreAction(_ sender: Any) {
        
        //creates the action sheet to logout.
        
        let myActionSheet = UIAlertController(title: "Options", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let Logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (action) in
            
            
            self.setupProfile()
            try! FIRAuth.auth()?.signOut()
            self.LogoutSeq()
            
        }
        
        myActionSheet.addAction(Logout)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    }

    
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}
