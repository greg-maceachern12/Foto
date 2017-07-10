
//
//  NewPostViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-04-29.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

struct postStruct {
    let title: String!
    let price: Int!
    let date: String!
    let picture: FIRDatabaseReference!
    let token: String!
}

class NewPostViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate {
    
    
    @IBOutlet weak var tbTitle: UITextField!
    @IBOutlet weak var tbPrice: UITextField!
    @IBOutlet weak var Date: UIDatePicker!
    @IBOutlet weak var btnPost: UIButton!

    var dataRef = FIRDatabase.database().reference()
    let storageRef = FIRStorage.storage().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnPost.layer.cornerRadius = 7
    }
    
    //function to remove placeholder text
    func textViewDidBeginEditing(_ textView: UITextView) {
        
//        if (tbDescription.textColor == UIColor.lightGray || tbDescription.text == "Enter A Detailed Description")
//        {
//            tbDescription.text = ""
//            tbDescription.textColor = UIColor.black
//        }
    }
    
    //code for cancel
    @IBAction func didCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

            //dismisses the keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tbPrice.resignFirstResponder()
        tbTitle.resignFirstResponder()
        return false
    }
   
    
    

    //code for posting
    @IBAction func didPost(_ sender: Any) {
        
        //If there is text in both boxes
        if (tbPrice.text!.characters.count > 0 && tbTitle.text != "")
        {
 
            dataRef.child("users").child(loggedUser!.uid).observeSingleEvent(of: .value, with: {  (snapshot) in
                
                
                let dict = snapshot.value as? [String: AnyObject]
            
            
                let profileImageURL = dict?["pic"] as? String
                
                if profileImageURL == nil
                {
                    let alertContoller = UIAlertController(title: "Oops!", message: "Set A Profile Picture", preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertContoller.addAction(defaultAction)
                    
                    self.present(alertContoller, animated:true, completion: nil)
                }
                else
                {
                
                let url = URL(string: profileImageURL!)
                let urlText = url?.absoluteString
                
            
                let dateformatter = DateFormatter()
                dateformatter.dateStyle = DateFormatter.Style.short
                let dob = dateformatter.string(from: NSDate() as Date)
                
                
                
                let tableTitle = self.tbTitle.text
                let price = self.tbPrice.text
                    
                let token = self.loggedUser!.uid
              
                
                let post: [String : AnyObject] = ["name": tableTitle as AnyObject,
                                                  "about": price as AnyObject,
                                                  "date": dob as AnyObject,
                                                  "img": urlText as AnyObject,
                                                  "token": token as AnyObject]
                
                
                self.dataRef.child("posts").childByAutoId().setValue(post)
                self.dismiss(animated: true, completion: nil)
                }
                
            })
            
            
            
            //if the text boxes are blank, show the error
        }
        else
        {
            let alertContoller = UIAlertController(title: "Oops!", message: "Please Fill In Fields", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            
            self.present(alertContoller, animated:true, completion: nil)
        }
    }
    
    
}
