//
//  Login.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-03-10.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class Login: UIViewController, UITextFieldDelegate {
    
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
       // print("true")
        //self.Show()
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
        
        
        //checks to see if textbox is blank.
        
        
        
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
              
                
                //print("firstName \(firstTextField.text)")
                
                
                
                FIRAuth.auth()?.createUser(withEmail: self.tbUser.text!, password: self.tbPassword.text!, completion: { (user, error) in
                    
                    //if there is an error
                    
                    
                    //if no error
                    if error == nil
                    {
                        
                        self.loggedInUser = FIRAuth.auth()?.currentUser
                        self.btnLogout.alpha=1.0
                        self.tbUser.text = ""
                        self.tbPassword.text = ""
                        self.lblUser.text = user!.email
                        self.NameRef.child("users").child(self.loggedInUser!.uid).child("Name").setValue(firstTextField.text)
                         self.NameRef.child("users").child(self.loggedInUser!.uid).child("Email").setValue(FIRAuth.auth()?.currentUser?.email)

                    
                        
                        self.Load.stopAnimating()
                        UserDefaults.standard.set(false, forKey: "artistCreate")
                        self.Show()
                    }
                    else
                    {
                        let alertContoller = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alertContoller.addAction(defaultAction)
                        self.Load.stopAnimating()
                        self.present(alertContoller, animated:true, completion: nil)
                        
                    }
                    
                    
                    
                    
                    
                    //if error
                    
                })

                
                
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
        if self.tbUser.text == "" || self.tbPassword.text == ""
        {
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
    
    
    @IBAction func Logout(_ sender: Any) {
        
        //sign out and make lbl/btn/tb blank
        try! FIRAuth.auth()?.signOut()
        
        self.lblUser.text = "Sign In/Sign Up"
        self.btnLogout.alpha=0
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
                if snapshot.exists() == true
                {
                    UserDefaults.standard.set(true, forKey: "artistCreate")
                    
                }
                else
                {
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
            if snapshot.exists() == true
            {
                UserDefaults.standard.set(true, forKey: "artistCreate")
                
            }
            else
            {
                UserDefaults.standard.set(false, forKey: "artistCreate")
                
            }
        })
        
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc: UIViewController = storyboard.instantiateViewController(withIdentifier: "Home")
        
        
        self.present(vc, animated: true, completion: nil)
    }
}



