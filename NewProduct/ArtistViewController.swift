//
//  ArtistViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-05-11.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage



class ArtistViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tbDescription: UITextView!
    @IBOutlet weak var picturePicker: UIPickerView!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnPin: UIButton!
    @IBOutlet weak var btnBook: UIButton!
    @IBOutlet weak var Scroller: UIScrollView!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var lblPrice1: UILabel!
    @IBOutlet weak var lblPrice2: UILabel!
    @IBOutlet var Long1: UILongPressGestureRecognizer!
    @IBOutlet weak var NAVTitle: UINavigationItem!
    @IBOutlet var LongPrice: UILongPressGestureRecognizer!
    @IBOutlet var LongPrice2: UILongPressGestureRecognizer!
    @IBOutlet weak var imgVer: UIImageView!
    @IBOutlet weak var Stars: RatingView!

    var dataRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var Loader: UIActivityIndicatorView!
    
    var tracker: Int! = 0
    
    var status: String!
    
    var table1 = false
    var count = 0
//    var posts = [String?]()
//    var posts2 = [String?]()
    
    var posts:[String?] = ["Add Something!","Add Something!","Add Something!"]
    var posts2:[String?] = ["Add Something!","Add Something!","Add Something!"]
  
    
    var imagePicker = UIImagePickerController()
    var url: NSURL!
    var tempImg = UIImageView()
    
    var placeholderLabel: UILabel!
    var tempImg1 = UIImageView()
    var tempImg2 = UIImageView()
    var tempImg3 = UIImageView()
    
    var temp1: String!
    var temp2: String!
    var temp3: String!
    
    var tableNumber: Int!
    var uploadVar = true
    var uploadCount = 0
    
    var token: String!
    var artistname: String!
    var userIsVerfied = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        //setting the scroll view size
        Scroller.contentSize = CGSize(width: self.view.frame.width, height: 1410)
        
        
        //if the artist profile page is NOT the current user, disable the ability to edit
        if token != loggedUser?.uid
        {
            tbDescription.isUserInteractionEnabled = false
            Long1.isEnabled = false
            LongPrice.isEnabled = false
            LongPrice2.isEnabled = false
            
           
            
            dataRef.child("artistProfiles").child(self.token).child("Name").observe(.value){
                (snap: FIRDataSnapshot) in
                if snap.exists() == true
                {
                self.NAVTitle.title = "\(snap.value as! String)'s Profile"
                    self.artistname = snap.value as? String
                }
                else{
                    self.NAVTitle.title = ""
                }
            }
        }
        else
        {
            dataRef.child("artistProfiles").child(self.token).child("Name").observe(.value){
                (snap: FIRDataSnapshot) in
                self.NAVTitle.title = "\(snap.value as! String) (Your Profile)"
                self.btnPin.isHidden = true
                self.btnBook.isHidden = true
                self.btnMessage.isHidden = true
            }
        }
        
        
       // print(posts)
        
        
        //setting placeholder text for the textview
        tbDescription.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        placeholderLabel.numberOfLines = 4
        placeholderLabel.text = "Give your clients some information about yourself \n Eg. Where you're from \n Eg. The equipment you use \n Eg. Links to websites/other portals"
        placeholderLabel.font = UIFont(name: "Avenir Next", size: 14)
        placeholderLabel.sizeToFit()
        tbDescription.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (tbDescription.font?.pointSize)!/2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !tbDescription.text.isEmpty
        
        SetUp()
        SetPic()
        
       
    
        
        // Do any additional setup after loading the view.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        tbDescription.resignFirstResponder()
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        placeholderLabel.isHidden = !tbDescription.text.isEmpty
    }
 
  
 
    func textViewDidChange(_ textView: UITextView) {
       self.dataRef.child("artistProfiles").child(token).child("About").setValue(tbDescription.text)
        
    }
    
    
    
    ////////////////////////////////////////////////////////////////////////////////

    
    
    
                            //PICKER VIEW FUNCTIONS
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 172
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        tracker = row
        //print(tracker)
        
    }
    

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        //declaring the things which will be in the pickerview
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 172))
        let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 172))
        Loader = UIActivityIndicatorView(frame: CGRect(x: pickerView.frame.width/2, y: 66, width: 40, height: 40))
        let myLabel = UILabel(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 172))
        myLabel.textAlignment = NSTextAlignment.center
        myLabel.backgroundColor = UIColor.clear
        
        
        var rowString = String()
  
        
        Loader.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        Loader.color = UIColor(red: 253/255, green: 133/255, blue: 8/255, alpha: 1)
        Loader.startAnimating()
    
        myImageView.image = #imageLiteral(resourceName: "Default")
        

            //initializing the picker rows data
        switch row {
        case 0:
            if tempImg1.image != nil && tempImg1.image != #imageLiteral(resourceName: "Verfied")
            {
                
                myImageView.image = tempImg1.image
                Loader.stopAnimating()
               
            }
            else if tempImg1.image == #imageLiteral(resourceName: "Verfied")
            {
                Loader.stopAnimating()
            }
            else{
                    Loader.startAnimating()
            }
            //
            
        case 1:
            if tempImg2.image != nil && tempImg2.image != #imageLiteral(resourceName: "Verfied")
            {
                
                myImageView.image = tempImg2.image
                Loader.stopAnimating()
                
            }
            else if tempImg2.image == #imageLiteral(resourceName: "Verfied")
            {
                Loader.stopAnimating()
            }
            else{
                Loader.startAnimating()
            }

        case 2:
            if tempImg3.image != nil && tempImg3.image != #imageLiteral(resourceName: "Verfied")
            {
                
                myImageView.image = tempImg3.image
                Loader.stopAnimating()
                
            }
            else if tempImg3.image == #imageLiteral(resourceName: "Verfied")
            {
                Loader.stopAnimating()
            }
            else{
                Loader.startAnimating()
            }
        
        case 3: break
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }
        
        
        myLabel.text = rowString
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        myView.addSubview(Loader)
        return myView
    }
    
    
    
    //method for setting an image and saving it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
      
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
            //ugh.image = selectedImage2 as UIImage
            tempImg.image = selectedImage2 as UIImage
            
        }
        
        //very important. This keeps track of which row was clicked to have the image uploaded. Overall, using the pickercontroller was inefficient and was very slow. Might change
       
            if (tracker == 0)
            {
                status = "ProfilePic1"
                tempImg1.image = tempImg.image
                
                UploadImage()
            }
                
            else if (tracker == 1)
            {
                status = "ProfilePic2"
                tempImg2.image = tempImg.image
                
                UploadImage()
            }
            else if tracker == 2
            {
                status = "ProfilePic3"
                tempImg3.image = tempImg.image
                
                UploadImage()
            }
            
        
        dismiss(animated: true, completion: nil)
    
    }
    
    
    @IBAction func longPressPicker(_ sender: UILongPressGestureRecognizer) {
        
        
        
        
        // this is for whena  row is long pressed to change the image
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        let myActionSheet = UIAlertController(title: "Memory Picture", message: "Select", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
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
        
        
        
        myActionSheet.addAction(photoGallery)
        myActionSheet.addAction(camera)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
                                //Uploading Images
    func UploadImage(){
        
        let imageName =  NSUUID().uuidString
        //let imageNameCover = NSUUID().uuidString
        
        let storedImage = storageRef.child("imgProfile").child(self.token).child(imageName)

        
        
        if let uploadData = UIImagePNGRepresentation(self.tempImg.image!)
        {
                storedImage.put(uploadData, metadata: nil, completion: { ( metadata, error) in
                    if error != nil
                    {
                        //print(error!)
                        return
                    }
                    storedImage.downloadURL(completion: { (url,error) in
                        if error != nil
                        {
                           // print(error!)
                            return
                        }
                        if let urlText = url?.absoluteString{
                            self.dataRef.child("artistProfiles").child(self.token).updateChildValues(["\(self.status!)" : urlText], withCompletionBlock: { (error,ref) in
                                if error != nil
                                {
                                    
                                    //print(error!)
                                    return
                                }
                                let imgData = UIImagePNGRepresentation(self.tempImg.image!)! as NSData
                                UserDefaults.standard.set(imgData, forKey: "\(self.status!) \(self.token!)")
                                
                            })
                        }
                    })
                })
            }
        
        
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    
    
    
                    //TABLE FUNCTIONS
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
//        if token == loggedUser?.uid
//        {
//            if tableView == tableView1
//            {
//                return posts.count + 1
//            }
//            else
//            {
//                return posts2.count + 1
//            
//            }
//        }
//        else
//        {
//            if tableView == tableView1
//            {
//                return posts.count
//            }
//            else
//            {
//                return posts2.count
//                
//            }
//        }
        return 3
    }
    
        
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //sets the label in the cell to be data from the array "posts" which is a string of values grabbed from the database
        
        
        
        if tableView == tableView1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            let tb1 = cell?.viewWithTag(1) as! UITextView
            tb1.text = posts[indexPath.row]!
            
            return cell!
        }
            
        else
        {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2")
            
            let tb1 = cell2?.viewWithTag(2) as! UITextView
            tb1.text = posts2[indexPath.row]!
            
            return cell2!
            
        }
        
        
//        
//        if tableView == tableView1
//        {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
//        //print(posts.count)
//            let tb1 = cell?.viewWithTag(1) as! UITextView
//            tb1.text = posts[indexPath.row]!
//            
//            return cell!
        
//               if indexPath.row == posts.count
//               {
//                let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//                let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//                button.backgroundColor = UIColor.clear
//                button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
//                myImageView.image = #imageLiteral(resourceName: "Add")
//                
//                let tb1 = cell?.viewWithTag(1) as! UITextView
//                tb1.isHidden = true
//                
//                
//                
//                cell?.addSubview(myImageView)
//                cell?.addSubview(button)
//                return cell!
//                
//                
//                }
//               
//               else {
//                
//                //print(indexPath.row)
//                let tb1 = cell?.viewWithTag(1) as! UITextView
//                tb1.text = posts[indexPath.row]!
//                
//                return cell!
//                
//                }
            
//        }
//    
//    
//        else
//        {
//            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2")
//            
//            if indexPath.row == posts2.count
//            {
//                let myImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//                let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
//                button.backgroundColor = UIColor.clear
//                button.addTarget(self, action: #selector(pressButton(button:)), for: .touchUpInside)
//                myImageView.image = #imageLiteral(resourceName: "Add")
//                
//                let tb1 = cell2?.viewWithTag(2) as! UITextView
//                tb1.isHidden = true
//                
//                
//                
//                cell2?.addSubview(myImageView)
//                cell2?.addSubview(button)
//                return cell2!
//                
//                
//            }
//                
//            else {
//                
//                print(indexPath.row)
//                let tb1 = cell2?.viewWithTag(2) as! UITextView
//                tb1.text = posts2[indexPath.row]!
//                
//                return cell2!
//                
//            }
//            
//        }
        
    }
    
    

    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if token == loggedUser?.uid
        {
        return true
        }
        else{
            return false
        }
    }
    
    func pressButton(button: UIButton) {
        if posts.count <= 5
        {
       posts.append("Adding Something")
        
        tableView1.insertRows(at: [IndexPath(row: posts.count-1, section: 0)], with: .automatic)
        
        //print(posts)
        }
        else
        {
            let alertContoller = UIAlertController(title: "Oops!", message: "Only 5 conditions allowed", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated:true, completion: nil)
        }
    }
    
    
    @IBAction func LongPrice1(_ sender: UILongPressGestureRecognizer) {
        let alertController = UIAlertController(title: "Edit Pricing", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            firstTextField.keyboardType = UIKeyboardType.decimalPad
            
            if firstTextField.text == ""
            {
                
            }
            else
            {
                
                
                self.lblPrice1.text = "$\(firstTextField.text!)"
                self.dataRef.child("artistProfiles").child(self.token).child("Price1").setValue(Float(firstTextField.text!))
                
                
                
                
            }
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Describe this pricing"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.tableView1.reloadData()
        self.present(alertController, animated: true, completion: nil)
        
        
        //print("true")
        

    }
    
    @IBAction func LongPressPrice2(_ sender: UILongPressGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Edit Pricing", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
            alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            firstTextField.keyboardType = UIKeyboardType.decimalPad
            
            if firstTextField.text == ""
            {
                
            }
            else
            {
                
                
                self.lblPrice2.text = "$\(firstTextField.text!)"
                self.dataRef.child("artistProfiles").child(self.token).child("Price2").setValue(Float(firstTextField.text!))
                
                
                
                
            }
            
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
            
        })
        
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Describe this pricing"
        }
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
    
        //swipe to edit feature
          if token == loggedUser?.uid
          {
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                //What happens when Edit button is tapped
                self.count = index.row
                
                
                
                
                    if tableView == self.tableView1
                    {
                         self.posts.remove(at: index.row)
                        
                        self.dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_\(self.count)").removeValue()
                        
                            self.tableView1.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                        
                        //print(self.posts)
                        
                    }
                        
                    else
                    {
                         self.posts2.remove(at: index.row)
                        
                        self.dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_\(self.count)").removeValue()
                        
                            self.tableView2.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                        
                        
                        
                    }
                    
                    
            }
            
            
            
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            //What happens when Edit button is tapped
            self.count = index.row

            
            let alertController = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField
                
                if firstTextField.text == ""
                {
                    
                }
                else
                {
                    
               
                        if tableView == self.tableView1
                        {
                             self.dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_\(index.row)").setValue(firstTextField.text)
                            //print(index.row)
                           // self.posts[index.row] = firstTextField.text
                            //print(self.posts)
                        }
                            
                        else
                        {
                            self.dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_\(self.count)").setValue(firstTextField.text)
                            
                            self.posts2[self.count] = firstTextField.text
                            
                        }
                    
                   
                        
                        
                    }
                
            
                
            })
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                
                
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Describe this pricing"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
 
        }
            
            
            
            
        edit.backgroundColor = .blue
        
            
        
        return [edit, delete]
        
        }
        else
          {
            return nil
        }
        
    }
    
    
    
    @IBAction func btnMoreAction(_ sender: Any) {
 
        
    }
    
    

    
    
    func SetUp(){
       
        
        btnPin.layer.cornerRadius = 5
        btnPin.clipsToBounds = true
        
        btnBook.layer.cornerRadius = 5
        btnBook.clipsToBounds = true
        
        btnMessage.layer.cornerRadius = 5
        btnMessage.clipsToBounds = true
        
        
        self.dataRef.child("artistProfiles").child(self.token).child("Verified").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                self.imgVer.isHidden = false
            }
            else
            {
                
               self.imgVer.isHidden = true
            }
            
        }

        
        dataRef.child("artistProfiles").child(self.token).child("pic").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true{
            if let pic = snap.value as? String{
                self.url = NSURL(string:pic)
                
                }
            }
        }
        
        
       
        
        dataRef.child("artistProfiles").child(self.token).child("About").observe(.value){
            (snap: FIRDataSnapshot) in
            self.tbDescription.text = snap.value as? String
            
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Rating").observe(.value){
            (snap: FIRDataSnapshot) in
            self.Stars.rating = (snap.value as? Float)!
            
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Price1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
            self.lblPrice1.text = "$\(snap.value! as! Float)"
            }
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Price2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                self.lblPrice2.text = "$\(snap.value! as! Float)"
            }
        }
        
        if tbDescription.text == ""{
            
            tbDescription.text = "Enter A Detailed Description"
            tbDescription.textColor = UIColor.lightGray
            
        }
        dataRef.child("artistProfiles").child(self.token).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblName.text = snap.value as? String
        }
        
        //Table1
    
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_0").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts[0] = temp1!
                self.tableView1.reloadData()
            }
            else{
//                self.posts.insert("Add Something!", at: 0)
            }
        }
        
        
       

        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
              
                self.posts[1] = temp1!
                self.tableView1.reloadData()
            }
            else{
//               self.posts.insert("Add Something!", at: 1)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts[2] = temp1!
                self.tableView1.reloadData()
            }
            else{
//               self.posts.insert("Add Something!", at: 2)
            }
     
        }
        
//        dataRef.child("artistProfiles").child(self.token).child("Price1").child("Price1_3").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//               // self.posts.remove(at: 3)
//                self.posts.insert(temp1!, at: 3)
//                self.tableView1.reloadData()
//            }
//            else{
//                //self.posts.remove(at: 3)
//            }
//            
//        }
//        dataRef.child("artistProfiles").child(self.token).child("Price1").child("Price1_4").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//               // self.posts.remove(at: 4)
//                self.posts.insert(temp1!, at: 4)
//                self.tableView1.reloadData()
//            }
//            else{
//               // self.posts.remove(at: 4)
//            }
//            
//        }
        
        
//
//        dataRef.child("artistProfiles").child(self.token).child("Price1").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
//            //
//            
//                 
//                    if snapshot.exists() == true{
//                        
//                        let snapshotValue = snapshot.value as? NSDictionary
//                        let name = snapshotValue?["Price1_\(self.uploadCount)"] as? String
//                
//                        self.posts.insert(name, at: self.uploadCount)
//                        
//                        print("\(self.posts) okay man" )
//                        self.uploadCount = self.uploadCount + 1
//                    }
//                    else{
//                        self.uploadVar = false
//                    }
//
//            
//            })
        
        //Table2
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_0").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                 self.posts2[0] = temp1!
                self.tableView2.reloadData()
            }
            else{
//                self.posts2.insert("Add Something!", at: 0)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                 self.posts2[1] = temp1!
                self.tableView2.reloadData()
            }
            else{
//                self.posts2.insert("Add Something!", at: 1)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                 self.posts2[2] = temp1!
                self.tableView2.reloadData()
            }
            else{
//                self.posts2.insert("Add Something!", at: 2)
            }
            
        }
        
        
        

    }
    func SetPic()
    {
      
        
//        dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let profileURL = (snapshot.value as AnyObject!)!["ProfilePic1"] as! String! {
//                
//                let profileNSURL: NSURL = NSURL(string: profileURL)!
//                
//                // download avatar image here somehow!?
//                let manager: SDWebImageManager = SDWebImageManager.shared()
//                manager.downloadImage(with: profileNSURL as URL!, options: [], progress: { (receivedSize: Int, actualSize: Int) in
//                    print(receivedSize, actualSize)
//                }, completed: { (image, error, cached, finished, url) in
//                    if image != nil {
//                        manager.imageCache.store(image, forKey: "\(self.token) pic1")
//                        
//                        DispatchQueue.main.async
//                            {
//                                
//                                self.tempImg1.image = image
//                                //avatarImage!.avatarHighlightedImage = image
//                        }
//                    }
//                    else{
//                        self.tempImg1.image = #imageLiteral(resourceName: "Verfied")
//                    }
//                })
//            }
//        })
//        
//
//        dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let profileURL = (snapshot.value as AnyObject!)!["ProfilePic2"] as! String! {
//                
//                let profileNSURL: NSURL = NSURL(string: profileURL)!
//                
//                // download avatar image here somehow!?
//                let manager: SDWebImageManager = SDWebImageManager.shared()
//                manager.downloadImage(with: profileNSURL as URL!, options: [], progress: { (receivedSize: Int, actualSize: Int) in
//                    print(receivedSize, actualSize)
//                }, completed: { (image, error, cached, finished, url) in
//                    if image != nil {
//                        manager.imageCache.store(image, forKey: "\(self.token) pic2")
//                        
//                        DispatchQueue.main.async
//                            {
//                                
//                                self.tempImg2.image = image
//                                //avatarImage!.avatarHighlightedImage = image
//                        }
//                    }
//                    else{
//                        self.tempImg2.image = #imageLiteral(resourceName: "Verfied")
//                    }
//                })
//            }
//        })
//        
//        
//        dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: { (snapshot) in
//            
//            if let profileURL = (snapshot.value as AnyObject!)!["ProfilePic3"] as! String! {
//                
//                let profileNSURL: NSURL = NSURL(string: profileURL)!
//                
//                // download avatar image here somehow!?
//                let manager: SDWebImageManager = SDWebImageManager.shared()
//                manager.downloadImage(with: profileNSURL as URL!, options: [], progress: { (receivedSize: Int, actualSize: Int) in
//                    print(receivedSize, actualSize)
//                }, completed: { (image, error, cached, finished, url) in
//                    if image != nil {
//                        manager.imageCache.store(image, forKey: "\(self.token) pic3")
//                        
//                        DispatchQueue.main.async
//                            {
//                                
//                                self.tempImg3.image = image
//                                //avatarImage!.avatarHighlightedImage = image
//                        }
//                    }
//                    else{
//                        self.tempImg3.image = #imageLiteral(resourceName: "Verfied")
//                    }
//                })
//            }
//        })
        
        //saving userdefaults
    
        if UserDefaults.standard.object(forKey: "ProfilePic1 \(self.token!)") == nil {
            dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    
                    
                    
                    if let profileImageURL = dict["ProfilePic1"] as? String
                    {
                        
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil{
                                //print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                               // print(data!)
                                if data == nil
                                {
                                
                                    
                                }
                                else
                                {
                                    

                                    
                                    self.tempImg1.image = UIImage(data: data!)
                                    
                                    let imgData = UIImagePNGRepresentation(self.tempImg1.image!)! as NSData
                                    UserDefaults.standard.set(imgData, forKey: "ProfilePic1 \(self.token!)")
                                    
                                   
                                    
                                    
                                    
                                }
                                
                                
                            }
                        }).resume()
                    }
                    else{
                        self.tempImg1.image = #imageLiteral(resourceName: "Verfied")
                    }
                }
            
            })
        }
        else{
            let imgdata2 = UserDefaults.standard.object(forKey: "ProfilePic1 \(self.token!)") as! NSData
            self.tempImg1.image = UIImage(data: imgdata2 as Data)
           // print(imgdata2)
        }
    
      if UserDefaults.standard.object(forKey: "ProfilePic2 \(self.token!)") == nil {
            dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    
                    
                    if let profileImageURL = dict["ProfilePic2"] as? String
                    {
                        
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil{
                                //print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                               // print(data!)
                                if data == nil
                                {
                                   // print("nil")
                                    
                                }
                                else
                                {
                                    self.tempImg2.image = UIImage(data: data!)
                                    let imgData = UIImagePNGRepresentation(self.tempImg2.image!)! as NSData
                                    UserDefaults.standard.set(imgData, forKey: "ProfilePic2 \(self.token!)")
                                  
                                }
                                
                                
                            }
                        }).resume()
                    }
                    else{
                        self.tempImg2.image = #imageLiteral(resourceName: "Verfied")
                    }
                }
                
            })
        
        }
      else{
        let imgdata2 = UserDefaults.standard.object(forKey: "ProfilePic2 \(self.token!)") as! NSData
        self.tempImg2.image = UIImage(data: imgdata2 as Data)
      
        
        }
        if UserDefaults.standard.object(forKey: "ProfilePic3 \(self.token!)") == nil {
            dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    
                    
                    if let profileImageURL = dict["ProfilePic3"] as? String
                    {
                        
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil{
                               // print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                               // print(data!)
                                if data == nil
                                {
                                 //   print("nil")
                                    
                                }
                                else
                                {
                                    self.tempImg3.image = UIImage(data: data!)
                                    let imgData = UIImagePNGRepresentation(self.tempImg3.image!)! as NSData
                                    UserDefaults.standard.set(imgData, forKey: "ProfilePic3 \(self.token!)")
                                    
                                }
                                
                                
                            }
                        }).resume()
                    }
                    else{
                        self.tempImg3.image = #imageLiteral(resourceName: "Verfied")
                    }
                }
                
            })
        }
        else{
            let imgdata2 = UserDefaults.standard.object(forKey: "ProfilePic3 \(self.token!)") as! NSData
            self.tempImg3.image = UIImage(data: imgdata2 as Data)
            
        }
    }
    
    ///////////////////
    
    @IBAction func btnBook(_ sender: Any) {
        let myVC = storyboard?.instantiateViewController(withIdentifier: "booking") as! BookingViewController
        
        myVC.userID = self.token
        
        //            print(myVC.token)
        self.present(myVC, animated: true)
    }
    
    @IBAction func message(_ sender: Any) {
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "Mess") as! MessViewController
        
        myVC.token = self.token
        myVC.name = self.artistname
        
        //            print(myVC.token)
        self.present(myVC, animated: true)
        
    }
    
    
    @IBAction func backShow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
