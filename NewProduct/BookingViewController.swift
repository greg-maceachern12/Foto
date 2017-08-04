//
//  BookingViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-02.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import MessageUI


class BookingViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var lblPrice1: UILabel!
    @IBOutlet weak var lblPrice2: UILabel!
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var dateWheelStart: UIDatePicker!
    @IBOutlet weak var dateWheelEnd: UIDatePicker!
    @IBOutlet weak var tvNotes: UITextView!
    @IBOutlet weak var tbTheme: UITextField!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    @IBOutlet weak var viewTab1: UIView!
    @IBOutlet weak var viewTab2: UIView!

    var placeholderLabel: UILabel!
    
    var posts = [String!]()
    var posts2 = [String!]()
    var loggedUser = FIRAuth.auth()?.currentUser
    var dataRef = FIRDatabase.database().reference()
    var userID: String!
    var count: Int!
    var name: String!
    
    var artistName: String!
    
    var userName: String!
    var email: String!
    
    var price11: Float!
    var price12: Float!
    var pricingOption: Float!
    var price1 = false
    var price2 = false
    var price3 = false
    var postRef = [String!]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNext.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.9), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])
        
        viewTab1.applyGradient(colours: [UIColor(red: 255/255, green: 189/255, blue: 89/255, alpha: 1.0), UIColor(red: 1.0, green: 139/255, blue: 26/255, alpha: 1.0)])
        viewTab2.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.0), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])
//        viewTab1.applyGradient(colours: [UIColor(red: 179/255, green: 0, blue: 255/255, alpha: 1.0), UIColor(red: 149/255, green: 0, blue: 245/255, alpha: 1.0)])
//        viewTab2.applyGradient(colours: [UIColor(red: 151/255, green: 0, blue: 255/255, alpha: 1.0), UIColor(red: 121/255, green: 0, blue: 255/255, alpha: 1.0)])
        
        
        
        placeholderLabel = UILabel()
        placeholderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        placeholderLabel.numberOfLines = 4
        placeholderLabel.text = "Any other extra information you'd like to add. \n Accommodations? \n Things to bring? \n Sleeping Arrangements?"
        placeholderLabel.font = UIFont(name: "Avenir Next", size: 14)
        placeholderLabel.sizeToFit()
        tvNotes.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (tvNotes.font?.pointSize)!/2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !tvNotes.text.isEmpty
        
        tbTheme.delegate = self
        tvNotes.delegate = self
        scroller.delegate = self
    
        
        SetUp()


        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        tvNotes.inputAccessoryView = toolbar
      
        
        
        //print(takenPosts)
        // Do any additional setup after loading the view.
    }
    func doneClicked(){
        self.view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /////////////////////////////////////////////////////////////////
                        //Code for the textfields and textviews
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tbTheme.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        tbTheme.becomeFirstResponder()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        tvNotes.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        tvNotes.resignFirstResponder()
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        placeholderLabel.isHidden = !tvNotes.text.isEmpty
    }

    
    
    ////////////////////////////////////////////////////////////
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //sets the label in the cell to be data from the array "posts" which is a string of values grabbed from the database
        
        if tableView == tableView1
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            let tb1 = cell?.viewWithTag(1) as! UILabel
            tb1.text = posts[indexPath.row]!
            
            
            
            
            return cell!
            
        }
            
        else
        {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2")
            
            let tb1 = cell2?.viewWithTag(2) as! UILabel
            tb1.text = posts2[indexPath.row]!
            
           
            
            return cell2!
            
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableView1
        {
            //green colour
            
            //tableView1.backgroundColor = UIColor(red: 0/255, green: 225/255, blue: 77/255, alpha: 1)
            UIView.animate(withDuration: 0.65, animations: {
            
                self.tableView1.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
                self.tableView2.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                
                
                self.viewTab1.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
                self.viewTab2.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                //self.viewTab2.layer
                
                
                
                
                
            })
            
            //orange colour
            
            
            //tableView2.backgroundColor = UIColor.clear
            
            //viewTab2.applyGradient(colours: [UIColor(red: 151/255, green: 0, blue: 255/255, alpha: 1.0), UIColor(red: 121/255, green: 0, blue: 255/255, alpha: 1.0)])
            
            
            price1 = true
            price2 = false
            price3 = false
            
            pricingOption = price11
         
            
        }
        else if tableView == tableView2
        {
            //orange
            //viewTab1.applyGradient(colours: [UIColor(red: 255/255, green: 189/255, blue: 89/255, alpha: 1.0), UIColor(red: 1.0, green: 139/255, blue: 26/255, alpha: 1.0)])
            //tableView1.backgroundColor = UIColor.clear
           //lblPrice1.applyGradient(colours: [UIColor(red: 255/255, green: 140/255, blue: 0, alpha: 1.0), UIColor(red: 1.0, green: 103/255, blue: 0, alpha: 1.0)])
            
            UIView.animate(withDuration: 0.65, animations: {
                
                self.tableView2.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
                self.tableView1.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                
                self.viewTab2.transform = CGAffineTransform(scaleX: 1.07, y: 1.07)
                self.viewTab1.transform = CGAffineTransform(scaleX: 0.93, y: 0.93)
                
                
                
                
                
            })
           
            
            //green
            
            //lblPrice2.backgroundColor = UIColor(red: 36/255, green: 212/255, blue: 77/255, alpha: 1)
            
            //tableView2.backgroundColor = UIColor(red: 0/255, green: 225/255, blue: 77/255, alpha: 1)
            
            price1 = false
            price2 = true
            price3 = false
            
            pricingOption = price12
        }
        
        
       
    }
    
    func editEntry() -> [String] {
        if self.pricingOption == price12{
            return posts2
        }
        else if self.pricingOption == price11{
            return posts
        }
        else{
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView1.frame.height/4
    }

    

   func SetUp()
    {

        
        dataRef.child("artistProfiles").child(self.userID).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.name = snap.value as? String
            self.navTitle.title = snap.value as? String
        }
        
        dataRef.child("users").child(loggedUser!.uid).child("Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.userName = snap.value as? String
        }
        
        dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Email").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true{
            self.email = snap.value as! String
            }
            
            
        }
        
        dataRef.child("artistProfiles").child(self.userID).child("Price2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
            self.lblPrice2.text = "$\(snap.value as! Float)"
                self.price11 = snap.value as! Float
            }
            else {
                self.lblPrice2.text = "Not Set"
            }
            
        }
        
        dataRef.child("artistProfiles").child(self.userID).child("Price1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                self.lblPrice1.text = "$\(snap.value as! Float)"
                self.price12 = snap.value as! Float
            }
            else {
                self.lblPrice1.text = "Not Set"
            }
            
        }
        
        //Table1
        
        
        
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing1").child("Price1_0").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                self.posts.insert(temp1!, at: 0)
                self.tableView1.reloadData()
            }
            else{
                self.posts.insert("Nothing Here!", at: 0)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing1").child("Price1_1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts.insert(temp1!, at: 1)
                self.tableView1.reloadData()
            }
            else{
                self.posts.insert("Nothing Here!", at: 1)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing1").child("Price1_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts.insert(temp1!, at: 2)
                self.tableView1.reloadData()
            }
            else{
                self.posts.insert("Nothing Here!", at: 2)
            }
            
        }
        dataRef.child("artistProfiles").child(self.userID).child("Pricing1").child("Price1_3").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts.insert(temp1!, at: 3)
                self.tableView1.reloadData()
            }
            else{
                self.posts.insert("Nothing Here!", at: 3)
            }
            
        }
        
//        dataRef.child("artistProfiles").child(self.userID).child("Price1").child("Price1_3").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//                // self.posts.remove(at: 3)
//                self.posts.insert(temp1!, at: 3)
//                self.tableView1.reloadData()
//            }
//            else{
//                //self.posts.remove(at: 3)
//            }
//            
//        }
//        dataRef.child("artistProfiles").child(self.userID).child("Price1").child("Price1_4").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//                // self.posts.remove(at: 4)
//                self.posts.insert(temp1!, at: 4)
//                self.tableView1.reloadData()
//            }
//            else{
//                // self.posts.remove(at: 4)
//            }
//            
//        }
        
        
  
        
        //Table2
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing2").child("Price2_0").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                self.posts2.insert(temp1!, at: 0)
                self.tableView2.reloadData()
            }
            else{
                self.posts2.insert("Nothing Here!", at: 0)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing2").child("Price2_1").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts2.insert(temp1!, at: 1)
                self.tableView2.reloadData()
            }
            else{
                self.posts2.insert("Nothing Here!", at: 1)
            }
        }
        
        
        dataRef.child("artistProfiles").child(self.userID).child("Pricing2").child("Price2_2").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts2.insert(temp1!, at: 2)
                self.tableView2.reloadData()
            }
            else{
                self.posts2.insert("Nothing Here!", at: 2)
            }
            
        }
        dataRef.child("artistProfiles").child(self.userID).child("Pricing2").child("Price2_3").observe(.value){
            (snap: FIRDataSnapshot) in
            if snap.exists() == true
            {
                let temp1 = snap.value as? String
                
                self.posts2.insert(temp1!, at: 3)
                self.tableView2.reloadData()
            }
            else{
                self.posts2.insert("Nothing Here!", at: 3)
            }
            
        }
        
        
        
//        dataRef.child("artistProfiles").child(self.userID).child("Price2").child("Price2_3").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//                
//                self.posts2.insert(temp1!, at: 3)
//                self.tableView2.reloadData()
//            }
//            
//            
//        }
//        dataRef.child("artistProfiles").child(self.userID).child("Price2").child("Price2_4").observe(.value){
//            (snap: FIRDataSnapshot) in
//            if snap.exists() == true
//            {
//                let temp1 = snap.value as? String
//                
//                self.posts2.insert(temp1!, at: 4)
//                self.tableView2.reloadData()
//            }
//            
//            
//        }
        
        
        
        
        

    }
    
    @IBAction func minChange(_ sender: Any) {
        //dateWheelEnd.minimumDate = dateWheelStart.date
    }
    
    @IBAction func endChange(_ sender: Any) {
        //dateWheelStart.minimumDate = dateWheelEnd.date
    }
    
    @IBAction func cancelAction(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func generateRandomStringWithLength(length:Int) -> String {
        
        let randomString:NSMutableString = NSMutableString(capacity: length)
        
        let letters:NSMutableString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var i: Int = 0
        
        while i < length {
            
            let randomIndex:Int = Int(arc4random_uniform(UInt32(letters.length)))
            randomString.append("\(Character( UnicodeScalar( letters.character(at: randomIndex))!))")
            i += 1
        }
        
        return String(randomString)
    }
    
    
    @IBAction func nextAction(_ sender: Any) {
        
        
        
        if self.price2 == false && self.price1 == false
        {
            let alertContoller = UIAlertController(title: "Error", message:"No pricing option selected", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated: true, completion: nil)
        }
        
        if tbTheme.text == ""
        {
            let alertContoller = UIAlertController(title: "Error", message:"No theme entered", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertContoller.addAction(defaultAction)
            self.present(alertContoller, animated: true, completion: nil)
        }
        else
        {
            if self.price1 == true
            {
                postRef = posts
            }
            else if self.price2 == true
            {
                postRef = posts2
            }

        
            let dateFormatter = DateFormatter()
            
            dateFormatter.dateStyle = DateFormatter.Style.short
            dateFormatter.timeStyle = DateFormatter.Style.short
            
            let strDate = dateFormatter.string(from: self.dateWheelStart.date)
            
            
            let strDate2 = dateFormatter.string(from: self.dateWheelEnd.date)
            
        let alertContoller = UIAlertController(title: "Confirm", message:"You're about to invite \(self.name!) with this information \n \n Pricing Option: \(postRef) \n Start Date: \(strDate) \n End Date: \(strDate2)", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Confirm", style: .default, handler: {
            alert -> Void in
            
            self.btnNext.isHidden = true
            self.Loader.startAnimating()
            
            let accessCode = self.generateRandomStringWithLength(length: 20)
            
            let inquirePost: [String : AnyObject] = ["Client Name": self.userName as AnyObject,
                                                     "Client Email": self.email as AnyObject,
                                                     "toName": self.artistName as AnyObject,
                                                     "Start Date": strDate as AnyObject,
                                                     "End Date": strDate2 as AnyObject,
                                                     "Pricing Option": "\(self.pricingOption!): \(self.postRef)" as AnyObject,
                                                     "Extra Notes": self.tvNotes.text as AnyObject,
                                                     "code": accessCode as AnyObject,
                                                     "Theme": self.tbTheme.text as AnyObject,
                                                     
                                                     "Status": "Pending" as AnyObject,
                                                     "artistToken": self.userID as AnyObject,
                                                     "token": self.loggedUser!.uid as AnyObject]
   
            self.dataRef.child("artistProfiles").child(self.userID).child("Inquires").updateChildValues([accessCode : inquirePost], withCompletionBlock: { (error,ref) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    self.btnNext.isHidden = false
                    self.Loader.stopAnimating()
                    
                    return
                }
                
                self.Loader.stopAnimating()
                let alertContoller2 = UIAlertController(title: "Success!", message:"You have successfully sent an invitation!", preferredStyle: .alert)
                
                let defaultAction2 = UIAlertAction(title: "Okay", style: .default, handler: {
                    alert -> Void in
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                    
                    self.present(vc, animated: true, completion: nil)
                    
                })
                
                alertContoller2.addAction(defaultAction2)
                
                self.present(alertContoller2, animated: true, completion: nil)
                
            })

            
            
            
            self.dataRef.child("users").child(self.loggedUser!.uid).child("Sent Inquires").updateChildValues([accessCode : inquirePost], withCompletionBlock: { (error,ref) in
                if error != nil
                {
                    let alertContoller = UIAlertController(title: "Error", message: error! as? String, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
                    alertContoller.addAction(defaultAction)
                    self.present(alertContoller, animated: true, completion: nil)
                    
                    return
                }
                let alertContoller2 = UIAlertController(title: "Success!", message:"You have successfully sent an invitation!", preferredStyle: .alert)
                
                let defaultAction2 = UIAlertAction(title: "Okay", style: .default, handler: {
                    alert -> Void in
                    let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Home")
                    
                    self.present(vc, animated: true, completion: nil)
                    
                })
                
                alertContoller2.addAction(defaultAction2)
                
                self.present(alertContoller2, animated: true, completion: nil)
                
            })

            
            
            
           
            
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
            
        })
        alertContoller.addAction(defaultAction)
        alertContoller.addAction(cancelAction)
        
        self.present(alertContoller, animated: true, completion: nil)
        }
        
        
        
    }
    
        

}
