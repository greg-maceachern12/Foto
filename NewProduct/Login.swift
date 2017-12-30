//
//  Login.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-03-10.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class Login: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var lblUser: UILabel!
    @IBOutlet weak var tbUser: UITextField!
    @IBOutlet weak var tbPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnCreate: UIButton!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var Load: UIActivityIndicatorView!
    @IBOutlet weak var loginView: UIView!
    
    let NameRef = FIRDatabase.database().reference()
    var loggedInUser:AnyObject?
    var pickerGend = UIPickerView()
    var gender = "Male"
    let genders = ["Male", "Female", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.Load.stopAnimating()
        
        tbUser.delegate = self
        tbPassword.delegate = self
        
        btnCreate.layer.cornerRadius = 5
        btnLogin.layer.cornerRadius = 5
        
        btnLogout.isEnabled = false
        
        //if there is a user logged in
        if let user = FIRAuth.auth()?.currentUser
        {
           self.btnLogout.alpha = 1.0
           self.btnLogout.isEnabled = true
           self.tbUser.text = user.email
           self.lblUser.text = "Enter Password"
           
        }
            //there is not a user logged in
        else
        {
           self.btnLogout.alpha = 0
           self.lblUser.text = ""
            self.lblUser.text = "Sign In/Sign Up"
        }
        self.loginView.alpha = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.loginView.alpha = 1
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tbUser.resignFirstResponder()
        tbPassword.resignFirstResponder()
        return true
    }
    @IBAction func CreateAccount(_ sender: Any) {
        self.view.endEditing(true)
        
        //if blank show alert
        if self.tbUser.text == "" || self.tbPassword.text == ""
        {
            let alertContoller = UIAlertController(title: "Oops!", message: "Please Enter a Username/Password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            self.Load.stopAnimating()
            self.present(alertContoller, animated:true, completion: nil)
        }
        //Creates account
        else
        {
            self.Load.startAnimating()
            let alertController = UIAlertController(title: "Enter Your Name", message: "This cannot be changed", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let firstTextField = alertController.textFields![0] as UITextField

                    let vc = UIViewController()
                    vc.preferredContentSize = CGSize(width: 250,height: 150)
                    let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: 75, height: 50))
                    let text1 = UITextField(frame: CGRect(x: 75, y: 0, width: 175, height: 50))
                    let label2 = UILabel(frame: CGRect(x: 0, y: 40, width: 75, height: 50))
                    let text2 = UITextField(frame: CGRect(x: 75, y: 40, width: 175, height: 50))
 
                    
                    let label3 = UILabel(frame: CGRect(x: 0, y: 80, width: 75, height: 50))
                    self.pickerGend = UIPickerView(frame: CGRect(x: 75, y: 80, width: 175, height: 50))
                
                    self.pickerGend.dataSource = self
                    self.pickerGend.delegate = self
                    
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
                    
                    vc.view.addSubview(text2)
                    vc.view.addSubview(self.pickerGend)
                    vc.view.addSubview(text1)
                    vc.view.addSubview(label1)
                    vc.view.addSubview(label2)
                    vc.view.addSubview(label3)
                    let editRadiusAlert = UIAlertController(title: "Edit Your Information", message: "", preferredStyle: UIAlertControllerStyle.alert)
                    editRadiusAlert.setValue(vc, forKey: "contentViewController")
                    editRadiusAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
                        alert -> Void in
                        
                        if text1.text == "" {
                            let alertContoller = UIAlertController(title: "Oops!", message: "Enter A Location", preferredStyle: .alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertContoller.addAction(defaultAction)
                            self.Load.stopAnimating()
                            self.present(alertContoller, animated:true, completion: nil)
                            return
                        }
            
                        if text2.text! == "" || text2.text == nil || Int(text2.text!) == nil{
                            let alertContoller = UIAlertController(title: "Oops!", message: "Enter Your Age", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertContoller.addAction(defaultAction)
                            self.Load.stopAnimating()
                            self.present(alertContoller, animated:true, completion: nil)
                            return
                        }
                        
                        if Int(text2.text!)! <= 12{
                            
                            let alertContoller = UIAlertController(title: "Oops!", message: "You Must Be 12 Years Old To Use This Application", preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alertContoller.addAction(defaultAction)
                            self.Load.stopAnimating()
                            self.present(alertContoller, animated:true, completion: nil)

                            return
                        }
                        
                        
                        FIRAuth.auth()?.createUser(withEmail: self.tbUser.text!, password: self.tbPassword.text!, completion: { (user, error) in
                            if error == nil{
                                self.loggedInUser = FIRAuth.auth()?.currentUser
                                self.btnLogout.alpha=1.0
                                self.tbUser.text = ""
                                self.tbPassword.text = ""
                                self.lblUser.text = user!.email
                                self.NameRef.child("users").child(self.loggedInUser!.uid).child("Name").setValue(firstTextField.text)
                                self.NameRef.child("users").child(self.loggedInUser!.uid).child("Email").setValue(FIRAuth.auth()?.currentUser?.email)
                                
                                self.NameRef.child("users").child(self.loggedInUser!.uid).child("Gender").setValue(self.gender)
                                self.NameRef.child("users").child(self.loggedInUser!.uid).child("Location").setValue(text1.text)
                                self.NameRef.child("users").child(self.loggedInUser!.uid).child("Age").setValue(Int(text2.text!))
                                
                                self.Load.stopAnimating()
                                UserDefaults.standard.set(false, forKey: "artistCreate")
                                self.Show()
                            }
                            else {
                                let alertContoller = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertContoller.addAction(defaultAction)
                                self.Load.stopAnimating()
                                self.present(alertContoller, animated:true, completion: nil)
                                
                            }
                        })
                    }))
                    
                editRadiusAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alert -> Void in
                    self.Load.stopAnimating()
                    }))
                    self.present(editRadiusAlert, animated: true)
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                self.Load.stopAnimating()
                
            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter First and Last Name"
            }
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func LoginAction(_ sender: Any) {
        
        self.view.endEditing(true)
        self.Load.startAnimating()
        //if user's text field is empty when login is clicked
        if self.tbUser.text == "" || self.tbPassword.text == ""{
            let alertContoller = UIAlertController(title: "Oops!", message: "Please Enter a Username/Password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertContoller.addAction(defaultAction)
            self.Load.stopAnimating()
            self.present(alertContoller, animated:true, completion: nil)
        }
            
            //try to login
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.tbUser.text!, password: self.tbPassword.text!, completion: {(user, error) in
                
                //if theres no error
                if error == nil
                {
                    self.btnLogout.alpha=1.0
                    self.tbUser.text = ""
                    self.tbPassword.text = ""
                    self.lblUser.text = user!.email
                    self.Load.stopAnimating()
                    self.Show()
                
                }
                    //if there is an error
                else
                {
                    let alertContoller = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertContoller.addAction(defaultAction)
                    self.Load.stopAnimating()
                    self.present(alertContoller, animated:true, completion: nil)
                }
            })
        }
        
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gender = genders[row]
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
    
    @IBAction func Logout(_ sender: Any) {
        
        //sign out and make lbl/btn/tb blank
        try! FIRAuth.auth()?.signOut()
        
        self.lblUser.text = "Sign In/Sign Up"
        self.btnLogout.alpha = 0
        self.tbPassword.text = ""
        self.tbUser.text = ""
        
    }
    
    
    //if the user is logged in, open right away
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if FIRAuth.auth()?.currentUser != nil {
            
            self.Load.startAnimating()
            lblUser.text = "Logging You In"
            UIView.animate(withDuration: 0.5, animations: {
                
                self.loginView.layer.opacity = 1
            })
            tbUser.isEnabled = false
            tbPassword.isEnabled = false
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Home")
            
            self.present(vc, animated: true, completion: nil)
            
            self.NameRef.child("artistProfiles").child((FIRAuth.auth()?.currentUser!.uid)!).observe(.value, with: { (snapshot) in
                
                print(snapshot.value!)
                if snapshot.exists() == true {
                    UserDefaults.standard.set(true, forKey: "artistCreate")
                }
                else{
                     UserDefaults.standard.set(false, forKey: "artistCreate")
                }
            })
            
            
        }
    }
    
    //function to show the new page
    func Show()
    {
        self.NameRef.child("artistProfiles").child((FIRAuth.auth()?.currentUser!.uid)!).observe(.value, with: { (snapshot) in
            
            print(snapshot.value!)
            if snapshot.exists() == true{
                UserDefaults.standard.set(true, forKey: "artistCreate")
            }
            else{
                UserDefaults.standard.set(false, forKey: "artistCreate") 
            }
        })
        
        let VC: MessViewController = MessViewController()
        let token: [String: AnyObject] = [Messaging.messaging().fcmToken!: Messaging.messaging().fcmToken as AnyObject]
        VC.postToken(Token: token)
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Home")
        
        
        self.present(vc, animated: true, completion: nil)
    }
}



