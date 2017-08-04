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


class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var HomeTitle: UINavigationItem!
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
    @IBOutlet weak var homeTab: UITableView!
    
    //declarations for about section
    @IBOutlet weak var lblLoc: UILabel!
    @IBOutlet weak var lblBirth: UILabel!
    @IBOutlet weak var lblGend: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    
     //let pickerDate = UIDatePicker()
     var pickerGend = UIPickerView()
     //var pickerSkill = UIPickerView()
    
     let genders = ["Male", "Female", "Other"]
     //let skill = ["Sports", "Events", "Nature", "Conferences", "Weddings", "Tours"]
   
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

    //I was being lazy and made variables for these references
   let NameLoad = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("Name")
    let aboutLoad = FIRDatabase.database().reference().child("users").child((FIRAuth.auth()?.currentUser?.uid)!).child("About")
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        lblName.isUserInteractionEnabled = true
        btnSave.layer.mask?.cornerRadius = 5

        
            //if user is logged out
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            LogoutSeq()
            //this removes every saved thing
            
            
        }
        
        //set profile qualities
        self.HomeTitle.title = "Loading Data"
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
                
                
                
                
            }
            else
            {
                let alertContoller = UIAlertController(title: "Oops!", message: "No Artists!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertContoller.addAction(defaultAction)
                
                self.present(alertContoller, animated:true, completion: nil)
            }
            
            
            self.homeTab.reloadData()
            
            
        })

        
        
        //allow the profile pic to be clicked
        self.imgMain.isUserInteractionEnabled = true
        self.HomeTitle.title = "Home"
       
    }
    
   
    


    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
                                                    //SETTING UP THE PROFILE
    func setupProfile(){
        
//        self.NameRef.child("artistProfiles").child(self.user!.uid).child("token").observe(.value){
//            (snap: FIRDataSnapshot) in
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
                
                self.lblBirth.text = "Birthday: \(temp2)"
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
        
         //Now remove the object for the keys starting with "ProfilePic"
        
        for key in allKeys{

            if key.hasPrefix("ProfilePic"){
                UserDefaults.standard.removeObject(forKey: key)
            }
            
        }
        //UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)

        
        self.present(loginVC, animated: true, completion: nil)
        
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
                
                self.memories.remove(at: indexPath.row)
                
                
                
                self.homeTab.reloadData()
                
                })
                
 
            
                    //self.posts.remove(at: index.row)
        
                    //self.tableView1.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
        }
        return [delete]
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell69")

        
        
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
            let thumbnailImage = try imageGen.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
            
            let img4 = cell?.viewWithTag(4) as! UIImageView
            img4.image = UIImage(cgImage: thumbnailImage)
//            img4.layer.cornerRadius = 8
//            img4.clipsToBounds = true
            Loader.stopAnimating()
            
            
        
            
        }catch let err{
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
//        let alertController = UIAlertController(title: "Edit Information", message: "", preferredStyle: .alert)
//        
//        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
//            alert -> Void in
//            
//            
//            
//            
//            let firstTextField = alertController.textFields![0] as UITextField
//             firstTextField.placeholder = "Please enter a location (City/State/Country)"
//            
//            if firstTextField.text != ""
//            {
//               
//            
//                //print("firstName \(firstTextField.text)")
//                if let temp1 = firstTextField.text{
//                self.lblLoc.text = "Location: \(temp1)"
//                self.loc = temp1
//                //self.btnSave.isHidden = false
//                self.NameRef.child("users").child(self.user!.uid).child("Location").setValue(temp1)
//                    print(UserDefaults.standard.bool(forKey: "artistCreate"))
//                    print(self.artistCreate)
//                    print(UserDefaults.standard.bool(forKey: "artistOn"))
//                    if self.artistCreate == true{
//                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Location").setValue(temp1)
//                    }
//                    
//                }
//            }
//            
//            let secondTextField = alertController.textFields![1] as UITextField
//            secondTextField.placeholder = "Please enter a birthday(dd/mm/yy)"
//            if secondTextField.text == ""
//            {
//                
//            }
//            else
//            {
//                //print("firstName \(firstTextField.text)")
//                if let temp2 = secondTextField.text{
//                self.lblBirth.text = "Birthday: \(temp2)"
//                self.birth = temp2
//                //self.btnSave.isHidden = false
//                    self.NameRef.child("users").child(self.user!.uid).child("Birthday").setValue(temp2)
//                    
//                    if self.artistCreate == true{
//                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Birthday").setValue(temp2)
//                    }
//                }
//            }
//            
//            let thirdTextField = alertController.textFields![2] as UITextField
//            thirdTextField.placeholder = "Please enter a gender"
//            if thirdTextField.text == ""
//            {
//                
//            }
//            else
//            {
//                if let temp3 = thirdTextField.text{
//                
//                self.lblGend.text = "Gender: \(temp3)"
//                self.gend = temp3
//                //self.btnSave.isHidden = false
//                    self.NameRef.child("users").child(self.user!.uid).child("Gender").setValue(temp3)
//                    
//                    if self.artistCreate == true{
//                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Gender").setValue(temp3)
//                    }
//                }
//            }
//            
//            let fourthTextField = alertController.textFields![3] as UITextField
//            fourthTextField.placeholder = "Please enter some skills"
//            if fourthTextField.text == ""
//            {
//                
//            }
//            else
//            {
//                //print("firstName \(firstTextField.text)")
//                if let temp4 = fourthTextField.text{
//                self.lblID.text = "Skills: \(temp4)"
//                self.skills = temp4
//                //self.btnSave.isHidden = false
//                    self.NameRef.child("users").child(self.user!.uid).child("Skills").setValue(temp4)
//                    
//                    if self.artistCreate == true{
//                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Skills").setValue(temp4)
//                    }
//                }
//            }
//            
//            
//            
//            
//            
//        })
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
//            (action : UIAlertAction!) -> Void in
//            self.Loader.stopAnimating()
//            
//        })
//        
//        alertController.addTextField { (firstTextField : UITextField!) -> Void in
//            
//            if (self.lblLoc.text == "Location: Not Declared" || self.lblLoc.text == "Location:")
//            {
//            //firstTextField.placeholder = "Please enter a location (City/State/Country)"
//            }
//            else
//            {
//                firstTextField.text = self.loc
//            }
//           
//        }
//        alertController.addTextField { (secondTextField : UITextField!) -> Void in
//            if (self.lblBirth.text == "Birthday: Not Declared" || self.lblBirth.text == "Birthday:")
//            {
//               // secondTextField.placeholder = "Please enter a birthday (dd/mm/yyyy)"
//            }
//            else
//            {
//                secondTextField.text = self.birth
//            }
//            
//        }
//        alertController.addTextField { (thirdTextField : UITextField!) -> Void in
//            if (self.lblGend.text == "Gender: Not Declared" || self.lblGend.text == "Gender:")
//            {
//                //thirdTextField.placeholder = "Please enter a gender"
//            }
//            else
//            {
//                thirdTextField.text = self.gend
//            }
//            
//        }
//        alertController.addTextField { (fourthTextField : UITextField!) -> Void in
//            if (self.lblID.text == "Skills: Not Declared" || self.lblID.text == "Skills:")
//            {
//               // fourthTextField.placeholder = "Please enter your skills (necessary for artist account)"
//            }
//            else
//            {
//                fourthTextField.text = self.skills
//            }
//            
//        }
//        
//        alertController.addAction(saveAction)
//        alertController.addAction(cancelAction)
//        
//        self.present(alertController, animated: true, completion: nil)
        
        
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
        text2.placeholder = "Enter Your Birthday (DD/MM/YYYY)"
        
        label1.font = UIFont(name: "Avenir Next", size: 13)
        label2.font = UIFont(name: "Avenir Next", size: 13)
        label3.font = UIFont(name: "Avenir Next", size: 13)
        
        label1.text = "Location:"
        label2.text = "Birthdate:"
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
                    print(UserDefaults.standard.bool(forKey: "artistCreate"))
                    print(self.artistCreate)
                    print(UserDefaults.standard.bool(forKey: "artistOn"))
                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Location").setValue(temp1)
                    }
                    
                }
            }
            

            if text2.text == ""
            {

            }
            else
            {
                //print("firstName \(firstTextField.text)")
                if let temp2 = text2.text{
                self.lblBirth.text = "Birthday: \(temp2)"
                //self.birth = temp2
                //self.btnSave.isHidden = false
                    self.NameRef.child("users").child(self.user!.uid).child("Birthday").setValue(temp2)

                    if self.artistCreate == true{
                        self.NameRef.child("artistProfiles").child(self.user!.uid).child("Birthday").setValue(temp2)
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
        

        
        let myActionSheet = UIAlertController(title: "Options", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let Logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.default) { (action) in
            
            
            self.setupProfile()
            try! FIRAuth.auth()?.signOut()
            self.LogoutSeq()
            
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
        myActionSheet.addAction(Logout)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    }

    
    @IBAction func backClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
}
