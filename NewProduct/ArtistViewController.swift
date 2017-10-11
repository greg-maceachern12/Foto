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
import MobileCoreServices
import AVFoundation
import AVKit
import Cosmos



class ArtistViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIBarPositioningDelegate {

    @IBOutlet weak var viewPrice2: UIView!
    @IBOutlet weak var viewPrice1: UIView!
    @IBOutlet weak var viewTab1: UIView!
    @IBOutlet weak var viewTab2: UIView!
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
    @IBOutlet weak var NAVTitle: UILabel!
    @IBOutlet var LongPrice: UILongPressGestureRecognizer!
    @IBOutlet var LongPrice2: UILongPressGestureRecognizer!
    @IBOutlet weak var imgVer: UIImageView!
    @IBOutlet weak var Stars: CosmosView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var lblReviewNum: UILabel!
    @IBOutlet weak var skillField: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var edit: UIButton!


    var dataRef = FIRDatabase.database().reference()
    var storageRef = FIRStorage.storage().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var Loader: UIActivityIndicatorView!
    var price1: Float!
    var price2: Float!
    
    var arrayRating = [Double?]()
    
    var upTrack: Int! = 0
    var tracker: Int! = 0
    
    var status: String!
    
    var table1 = false
    var count = 0
    var times = 0
    
    let pickerNumber = 0
    
    var letEdit = false
    
    
    var artistRat = Double(0)
    
    var posts:[String?] = ["Length of Video?","Do You Offer Shadowing?","How Much Material Will You Accept?","Custom"]
    var posts2:[String?] = ["Length of Video?","Do You Offer Shadowing?","How Much Material Will You Accept?","Custom"]
  
    
    var imagePicker = UIImagePickerController()
    var url: NSURL!
    var tempImg = UIImageView()
    
    var placeholderLabel: UILabel!
    var tempImg1 = UIImageView()
    var tempImg2 = UIImageView()
    var tempImg3 = UIImageView()
    
    
    var tb1 = UITextView()
    var placeholder = UILabel()
    
    var temp1: String!
    var temp2: String!
    var temp3: String!
    
    var urlArray = [String!]()

    
    var tableNumber: Int!
    var uploadVar = true
    var uploadCount = 0
    
    var token: String!
    var artistname: String!
    var userIsVerfied = false
    
    var vidURL: URL!
    
    var countRat = Double(0.0)
    
    let dropDown = DropDown()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        //setting the scroll view size
        
         viewPrice2.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.0), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])
        
         viewPrice1.applyGradient(colours: [UIColor(red: 255/255, green: 189/255, blue: 89/255, alpha: 1.0), UIColor(red: 1.0, green: 139/255, blue: 26/255, alpha: 1.0)])
        
        viewTab1.applyGradient(colours: [UIColor(red: 255/255, green: 189/255, blue: 89/255, alpha: 1.0), UIColor(red: 1.0, green: 139/255, blue: 26/255, alpha: 1.0)])
        viewTab2.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.0), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])

        
        
        //if the artist profile page is NOT the current user, disable the ability to edit
        if token != loggedUser?.uid
        {
            tbDescription.isEditable = false
            edit.isHidden = true
            LongPrice.isEnabled = false
            LongPrice2.isEnabled = false
            skillField.isEnabled = false
            btnAdd.isHidden = true
            self.view.frame = CGRect(x: 0, y: 0, width: 1410, height: 1410)
         
            Scroller.contentSize = CGSize(width: self.view.frame.width, height: 1410)
            
             posts = ["Nothing Here!","Nothing Here!","Nothing Here!", "Nothing Here!"]
             posts2 = ["Nothing Here!","Nothing Here","Nothing Here!", "Nothing Here!"]
           
            btnPin.applyDesign()
            btnBook.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.9), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])
            
            btnMessage.applyDesign()
            
            dataRef.child("artistProfiles").child(self.token).child("Name").observe(.value){
                (snap: FIRDataSnapshot) in
                if snap.exists() == true
                {
                self.NAVTitle.text = "\(snap.value as! String)'s Profile"
                    self.artistname = snap.value as? String
                }
                else{
                    self.NAVTitle.text = ""
                }
            }
        }
        else
        {
            dataRef.child("artistProfiles").child(self.token).child("Name").observe(.value){
                (snap: FIRDataSnapshot) in
                if snap.exists() == true{
                self.NAVTitle.text = "\(snap.value as! String) (Your Profile)"
                    self.btnPin.isHidden = true
                    self.btnBook.isHidden = true
                    self.btnAdd.isHidden = false
                    self.btnMessage.isHidden = true
                    self.view.frame = CGRect(x: 0, y: 0, width: 375, height: 1390)
                    self.Scroller.contentSize = CGSize(width: self.view.frame.width, height: 1390)
                
                    
                
                }
            }
        }
        
        
        
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
        
        imgVer.sizeToFit()
        
        lblReviewNum.text = "\(self.times) Reviews"
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        tbDescription.inputAccessoryView = toolbar
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
    @IBAction func editProf(_ sender: Any) {
        if letEdit == false{
            
            tbDescription.alpha = 0
            skillField.alpha = 0
            tbDescription.isEditable = true
            skillField.isEnabled = true
        
            edit.setTitle("Save", for: .normal)
            
            UIView.animate(withDuration: 0.5, animations: {
            
            self.tbDescription.alpha = 1
            self.skillField.alpha = 1
            })
            
            letEdit = true
            
        }
        else{
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("About").setValue(tbDescription.text!)
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Skills").setValue(skillField.text!, withCompletionBlock: { (error,ref) in
               
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                
                
                    return
                }
                
                
            self.tbDescription.isEditable = false
            self.skillField.isEnabled = false
            self.letEdit = false
            self.edit.setTitle("Edit", for: .normal)
                
                })
        
        }
    }
    
    @objc func doneClicked(){
        self.view.endEditing(true)
    }

  

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        tbDescription.resignFirstResponder()
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView == tbDescription{
        placeholderLabel.isHidden = !tbDescription.text.isEmpty
        }else{
            placeholder.isHidden = !tb1.text.isEmpty
            
        }
    }
 
    
    
                            //PICKER VIEW FUNCTIONS
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        //since there are more than one pickerviews, the pickerview of interest must be specified
        if pickerView == picturePicker{
            if self.token == self.loggedUser!.uid{
        return 3
            }
            else{
                return self.urlArray.count
            }
        }
        else{
           return 6
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        if pickerView == picturePicker{
            return 172
        }
        else{
            return 25
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == picturePicker{
            tracker = row
        }
   
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
        Loader.color = UIColor.orange
        Loader.startAnimating()
    
        myImageView.image = #imageLiteral(resourceName: "Default")
        

            //initializing the picker rows thumbnail image
        switch row {
        case 0:
            //using the "verified" image as a placeholder. If the image is "verified", it couldn't find the image in firebase directory
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
                //picturePicker.reloadComponent(1)
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
                
                //picturePicker.reloadComponent(2)
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
    //uploading video to firebase
    func handleVideoSelectedForUrl(url: NSURL){
        
        self.Loader.startAnimating()
        
        
        let filename = NSUUID().uuidString
        let uploadTask = FIRStorage.storage().reference().child("Memories").child(filename).putFile(url as URL, metadata: nil, completion: { (metadata, error) in
            self.Loader.startAnimating()
            if error != nil{
                let alertContoller = UIAlertController(title: "Error", message: error as? String, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                alertContoller.addAction(defaultAction)
                self.Loader.stopAnimating()
                self.present(alertContoller, animated: true, completion: nil)
              
                return
            }
            
            if let storageUrl = metadata?.downloadURL()?.absoluteString{
                //self.vidURL = url as URL!
                
            self.dataRef.child("artistProfiles").child(self.token).child(self.status!).setValue(storageUrl)
                
                self.Loader.stopAnimating()
                
                
                
                let imgData = UIImagePNGRepresentation(self.tempImg.image!)! as NSData
                UserDefaults.standard.set(imgData, forKey: "\(self.status!) \(self.token!)")
                
                
                
                self.urlArray.insert(String(describing: url), at: self.upTrack!)
                print(self.urlArray[self.tracker!])
                //self.picturePicker.reloadComponent(self.tracker)
                //self.picturePicker.reloadInputViews()
                
                
                self.Loader.stopAnimating()
                
                
                //about to pass data and add text stuff
            }
            
            
        })
        
        uploadTask.observe(.progress) { (snapshot) in
            self.progressBar.isHidden = false
            print(snapshot.progress!.completedUnitCount as Any)
            
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
      

            self.progressBar.progress = Float(percentComplete)
            
            
            
            if self.progressBar.progress == 1{
                self.progressBar.isHidden = true
                self.picturePicker.isUserInteractionEnabled = true
            }
            else{
                self.picturePicker.isUserInteractionEnabled = false
            }
        }

    }
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        
    }
    //creates thumbnail for the video
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

    
    //method for selecting a video and saving it
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
      
        if let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL{
            
            
            vidURL = videoURL as URL!
            
            if let thumbnailImage = self.thumbNail(fileURL: videoURL)
            {
                self.tempImg.image = thumbnailImage
                
                
            }
            
            
        }
        
        dismiss(animated: true, completion: nil)
        
        //very important. This keeps track of which row was clicked to have the image uploaded.
       
            if (tracker == 0)
            {
                status = "ProfilePic1"
                tempImg1.image = tempImg.image
                
                
                upTrack = tracker
                handleVideoSelectedForUrl(url: vidURL! as NSURL)
            }
                
            else if (tracker == 1)
            {
                status = "ProfilePic2"
                tempImg2.image = tempImg.image
                
                upTrack = tracker
                
                handleVideoSelectedForUrl(url: vidURL! as NSURL)
            }
            else if tracker == 2
            {
                status = "ProfilePic3"
                tempImg3.image = tempImg.image
                
                upTrack = tracker
                
                handleVideoSelectedForUrl(url: vidURL! as NSURL)
            }
            
        
        //dismiss(animated: true, completion: nil)
    
    }
    
    @IBAction func addVideo(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum)
        {
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
            self.imagePicker.allowsEditing = true
            self.imagePicker.mediaTypes = [kUTTypeMovie as String]
            self.present(self.imagePicker, animated: true, completion: nil)
            
        }
    }
    
    
    
    @IBAction func longPressPicker(_ sender: UILongPressGestureRecognizer) {

        // this is for when a  row is long pressed to change the image
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        let myActionSheet = UIAlertController(title: "Portfolio", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        
        let play = UIAlertAction(title: "Play Video", style: UIAlertActionStyle.default) { (action) in
            print(self.urlArray[self.tracker!])
            if self.urlArray[self.tracker] != nil{
                print("play")
                let player = AVPlayer(url: URL(string:self.urlArray[self.tracker])!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                self.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
            else{
                print("no play")
            }
        }
        

        
        
        
        
        myActionSheet.addAction(play)
        myActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        self.present(myActionSheet, animated: true, completion: nil)
    
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    ///////////////////////////////////////////////////////////////////////////////////////
    
    
    
                    //TABLE FUNCTIONS
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82.5
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
        
        //this is going to be code to add more rows to the pricing. Still working on it
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
        
        //edit the pricing on one of your options
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
                
                self.price1 = Float(firstTextField.text!)
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
                
                self.price2 = Float(firstTextField.text!)
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
    
    func editMessage() -> String {
        
        //the message when a user tries to edit one of the pricing characteristics
        if self.count == 0{
            return "Length Of Video"
        }
        else if self.count == 1{
            return "Shadowing? If So, Add Details"
        }
        else if self.count == 2{
            return "Amount of Material"
        }
        else if self.count == 3{
            return "Custom Pricing"
        }
        else{
            return ""
        }
    }
    
    
    

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
    
        //swipe to edit feature
          if token == loggedUser?.uid
          {
            
            let delete = UITableViewRowAction(style: .destructive, title: "Delete") { action, index in
                //What happens when delete button is tapped
                self.count = index.row
                
    
                if self.posts[index.row] ==  "Length of Video?" || self.posts[index.row] ==  "Do You Offer Shadowing?" || self.posts[index.row] ==  "How Much Material Will You Accept?" || self.posts[index.row] ==  "Custom"
                {
                    return
                }
                else{
                    if tableView == self.tableView1
                    {
                   
                        self.dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_\(self.count)").removeValue()
                        
                        self.tableView1.reloadData()
                        
                        
                    }
                        
                    else
                    {
                        self.dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_\(self.count)").removeValue()
                        self.tableView2.reloadData()
                            self.tableView2.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)

                    }
                }
                
            }
            
            
            
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            //What happens when Edit button is tapped
            self.count = index.row

            
            let alertController = UIAlertController(title: "Edit Your Pricing", message: self.editMessage(), preferredStyle: .alert)
            
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
                            self.dataRef.child("artistProfiles").child(self.token).child("Pricing1").updateChildValues(["Price1_\(index.row)" : firstTextField.text!], withCompletionBlock: { (error,ref) in
                                if error != nil
                                {
                                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                    alertContoller.addAction(defaultAction)
                                    self.present(alertContoller, animated: true, completion: nil)
                                   
                                    
                                    return
                                }
                                
                              
                                self.posts[index.row] = firstTextField.text
                                self.tableView1.reloadData()
                                    
                                })

                        
                            
                            
                        }
                            
                        else
                        {
                            self.dataRef.child("artistProfiles").child(self.token).child("Pricing2").updateChildValues(["Price2_\(index.row)" : firstTextField.text!], withCompletionBlock: { (error,ref) in
                                if error != nil
                                {
                                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                                    
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                                    alertContoller.addAction(defaultAction)
                                    self.present(alertContoller, animated: true, completion: nil)
                                    
                                    
                                    return
                                }
                                
                                
                                self.posts2[index.row] = firstTextField.text
                                self.tableView2.reloadData()
                            })
                            
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
        dataRef.child("artistProfiles").child(self.token).child("Skills").observe(.value){
            (snap: FIRDataSnapshot) in
            self.skillField.text = snap.value as? String
            
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Rating").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true{
            self.Stars.rating = (snap.value as? Double)!
            }
            else{
                self.Stars.rating = 0
            }
            
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Price1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                self.price1 = snap.value! as! Float
                self.lblPrice1.text = "$\(snap.value! as! Float)"
            }
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Price2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                self.price2 = snap.value! as! Float
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
           
        }
        
        
       

        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
              
                self.posts[1] = temp1!
                self.tableView1.reloadData()
            }
          
        }
        
        dataRef.child("artistProfiles").child(self.token).child("Ratings").queryOrderedByKey().observe(.childAdded, with: { (snapshot) in
           
            
            self.countRat = snapshot.value as! Double + self.countRat
            
            self.times = self.times + 1
            self.Stars.rating = self.countRat
            
            

        })
        
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts[2] = temp1!
                self.tableView1.reloadData()
            }
            
     
        }
        dataRef.child("artistProfiles").child(self.token).child("Pricing1").child("Price1_3").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts[3] = temp1!
                self.tableView1.reloadData()
            }
           
            
        }
        
        

        
        //Table2
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_0").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                 self.posts2[0] = temp1!
                self.tableView2.reloadData()
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

        }
        
        
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                 self.posts2[2] = temp1!
                self.tableView2.reloadData()
            }
        
            
        }
        dataRef.child("artistProfiles").child(self.token).child("Pricing2").child("Price2_3").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts2[3] = temp1!
                self.tableView2.reloadData()
            }
           
            
        }
        
        
        

    }
    
    @IBAction func More(_ sender: Any) {
        
        
        //the rating view will popup with a self made alert view
        if self.token != self.loggedUser!.uid{
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 150)
        let pickerView2 = CosmosView(frame: CGRect(x: 40, y: 0, width: 250, height: 50))
        
            self.tb1 = UITextView(frame: CGRect(x: 0, y: 40, width: 250, height: 100))
            self.tb1.font = UIFont(name: "Avenir Next", size: 14)
            //self.placeholder = UILabel(frame: CGRect(x: 0, y: 40, width: 250, height: 100))
            pickerView2.emptyImage = #imageLiteral(resourceName: "RateEmp")
            pickerView2.filledImage = #imageLiteral(resourceName: "RateFul")
            pickerView2.starSize = 30
            
            tb1.delegate = self
            
            placeholder = UILabel()
            placeholder.lineBreakMode = NSLineBreakMode.byWordWrapping
            placeholder.numberOfLines = 1
            placeholder.text = "Enter your review for this artist!"
            placeholder.font = UIFont(name: "Avenir Next", size: 14)
            placeholder.sizeToFit()
            tb1.addSubview(placeholder)
            placeholder.frame.origin = CGPoint(x: 5, y: 48)
            placeholder.textColor = UIColor.lightGray
            placeholder.isHidden = !tb1.text.isEmpty
//
        vc.view.addSubview(pickerView2)
        vc.view.addSubview(tb1)
        vc.view.addSubview(placeholder)
        let editRadiusAlert = UIAlertController(title: "Rate This Artist", message: "", preferredStyle: UIAlertControllerStyle.alert)
        editRadiusAlert.setValue(vc, forKey: "contentViewController")
        editRadiusAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
            alert -> Void in
            
            
            self.dataRef.child("artistProfiles").child(self.token).child("Ratings").child(self.loggedUser!.uid).setValue(pickerView2.rating, withCompletionBlock: { (error,ref) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    return
                }
             
                print(self.arrayRating)
                print(self.countRat)
                self.countRat = self.countRat + pickerView2.rating
                self.times = self.times + 1
                self.artistRat = self.countRat / Double(self.times)
                self.Stars.rating = (self.artistRat)
                self.dataRef.child("artistProfiles").child(self.token).child("Rating").setValue(self.artistRat)
                self.countRat = 0
                
            })

            
        }))
        
        editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(editRadiusAlert, animated: true)
        }
        
    }
    
    
    

   
    func SetPic()
    {
      
 
        
        dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
            
            if let snapshotValueName = snapshot.value as? NSDictionary
            {
      
            self.urlArray.removeAll()
       
            for i in 1...3{
                
                
                self.urlArray.insert(snapshotValueName["ProfilePic\(i)"] as? String, at: i - 1)
                print(self.urlArray)

            }
            }
           
            
        })
        
    
        if UserDefaults.standard.object(forKey: "ProfilePic1 \(self.token!)") == nil {
            dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
                
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    
                    
                    print("herhe")
                    if let profileImageURL = dict["ProfilePic1"] as? String
                    {
                        print("herhe1")
                        
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil{
                                print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                               print("herhe2")
                                if data == nil
                                {
                                
                                    
                                }
                                else
                                {
                                    
                                    self.urlArray[0] = profileImageURL
//                                    self.urltemp1 = url
                                    
                                    if let thumbnailImage = self.thumbNail(fileURL: url! as NSURL)
                                    {
                                        print("wulst")
                                        self.tempImg1.image = thumbnailImage
                                        
                                        if let imgData = UIImagePNGRepresentation(self.tempImg1.image!) as NSData?{
                                        UserDefaults.standard.set(imgData, forKey: "ProfilePic1 \(self.token!)")
                                        }
                                    }
                                    
                                    //let imgData = UIImagePNGRepresentation(self.tempImg1.image!)! as NSData
                                    
                                    
                                    //self.tempImg1.image = UIImage(data: data!)
                                    
                                    
                                    
                                   
                                    
                                    
                                    
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
            print("herhe33")
           self.tempImg1.image = UIImage(data: imgdata2 as Data)
            
        }
    
      if UserDefaults.standard.object(forKey: "ProfilePic2 \(self.token!)") == nil {
            dataRef.child("artistProfiles").child(self.token).observeSingleEvent(of: .value, with: {  (snapshot) in
                print("here")
                if let dict = snapshot.value as? [String: AnyObject]
                {
                    
                    
                    if let profileImageURL = dict["ProfilePic2"] as? String
                    {
                        
                        let url = URL(string: profileImageURL)
                        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                            if error != nil{
//                                print(error!)
                                return
                            }
                            DispatchQueue.main.async {
                               print("there")
                                if data == nil
                                {
                                   // print("nil")
                                    
                                }
                                else
                                {
                                    self.urlArray[1] = profileImageURL
//                                    self.urltemp2 = url
                                    
                                    if let thumbnailImage = self.thumbNail(fileURL: url! as NSURL)
                                    {
                                        self.tempImg2.image = thumbnailImage
                                        if let imgData = UIImagePNGRepresentation(self.tempImg2.image!) as NSData?{
                                        UserDefaults.standard.set(imgData, forKey: "ProfilePic2 \(self.token!)")
                                        }
                                    }
                                    
                                  
                                   
                                  
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
        print("where")
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
                                    self.urlArray[2] = profileImageURL
                                    //self.urltemp3 = url
                                    
                                    
                                    if let thumbnailImage = self.thumbNail(fileURL: url! as NSURL)
                                    {
                                        self.tempImg3.image = thumbnailImage
                                        if let imgData = UIImagePNGRepresentation(self.tempImg3.image!) as NSData?{
                                        UserDefaults.standard.set(imgData, forKey: "ProfilePic3 \(self.token!)")
                                        }
                                    }
        
                                    
                                    //self.tempImg3.image = UIImage(data: data!)
                                    
                                    
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
        
        if price1 != nil || price2 != nil{
        
        let myVC = storyboard?.instantiateViewController(withIdentifier: "booking") as! BookingViewController
        
        myVC.userID = self.token
        myVC.artistName = self.artistname
        //            print(myVC.token)
        self.present(myVC, animated: true)
        }
        else{
            let alertContoller = UIAlertController(title: "Oops", message:"This Artist hasn't created any pricing options! \n Look for a different artist or message this one to update his/her profile!", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated: true, completion: nil)
        }
        
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

    @IBAction func Pin(_ sender: Any) {
        //sets the pin in the database
        self.dataRef.child("users").child(self.loggedUser!.uid).child("Pins").updateChildValues([self.token : self.token], withCompletionBlock: { (error,ref) in
            if error != nil
            {
                let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated: true, completion: nil)
                
                
                return
            }
            
            let alertContoller2 = UIAlertController(title: "Success!", message:"You have successfully pinned this artist to your profile!", preferredStyle: .alert)
            
            let defaultAction2 = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertContoller2.addAction(defaultAction2)
            
            self.present(alertContoller2, animated: true, completion: nil)
            
        })

        
    }

}
extension UIView {
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
}
