//
//  inquireViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-09.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase

class inquireViewController: UIViewController {
    
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblEnd: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var navTitle: UINavigationItem!
    @IBOutlet weak var imgprof: UIImageView!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!

    var loggedUser = FIRAuth.auth()?.currentUser
    var dataRef = FIRDatabase.database().reference()
    
    var code: String!
    var token: String!
    var clientEmail: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUp()
        uploadPic()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
func SetUp()
    {
        imgprof.layer.cornerRadius = imgprof.frame.width/2
        imgprof.clipsToBounds = true
        
        btnAccept.layer.cornerRadius = btnAccept.frame.height/2
        btnAccept.clipsToBounds = true
        
        btnDecline.layer.cornerRadius = btnDecline.frame.height/2
        btnDecline.clipsToBounds = true
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("Client Name").observe(.value){
            (snap: FIRDataSnapshot) in
            self.navTitle.title = "\(snap.value as! String)'s Inquire"
            self.lblName.text = snap.value as? String
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("Client Email").observe(.value){
            (snap: FIRDataSnapshot) in
            self.clientEmail = snap.value as? String
            //self.lblEmail.text = snap.value as? String
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("Start Date").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblStart.text = "Start Date: \(snap.value as! String)"
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("End Date").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblEnd.text = "End Date: \(snap.value as! String)"
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("Extra Notes").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblNotes.text = snap.value as? String
        }
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("token").observe(.value){
            (snap: FIRDataSnapshot) in
            self.token = snap.value as? String
        }
        
        
    }
  
    func uploadPic()
    {
        dataRef.child("users").child(token).observeSingleEvent(of: .value, with: {  (snapshot) in
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
                                self.imgprof?.image = UIImage(data: data!)
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
    
    @IBAction func Decline(_ sender: Any) {
        let alertContoller = UIAlertController(title: "Confirm!", message: "Are You Sure You Want To Decline This Inquire?", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            
            let alertContoller2 = UIAlertController(title: "Success!", message: "You Successfully Declined This Inquire", preferredStyle: .alert)
            
            let defaultAction2 = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertContoller2.addAction(defaultAction2)
            
            self.dataRef.child("users").child(self.token).child("Sent Inquires").child(self.code).child("Status").setValue("Declined")
            
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Inquires").child(self.code).child("Status").setValue("Declined")
            
            self.present(alertContoller2, animated:true, completion: nil)
            
        })
    
        alertContoller.addAction(yesAction)
        alertContoller.addAction(defaultAction)
        
        self.present(alertContoller, animated:true, completion: nil)
    }
    
    @IBAction func Accept(_ sender: Any) {
        
        let alertContoller = UIAlertController(title: "Confirm!", message: "Are You Sure You Want To Accept This Inquire?", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            
            self.lblEmail.text = self.clientEmail
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Inquires").child(self.code).child("Status").setValue("Accepted")

            self.dataRef.child("users").child(self.token).child("Sent Inquires").child(self.code).child("Status").setValue("Accepted")
            
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Messager") as! MessagesViewController
             myVC.token = self.token
          
            self.present(myVC, animated: true)
            
        })
        
        alertContoller.addAction(yesAction)
        alertContoller.addAction(defaultAction)
        
        self.present(alertContoller, animated:true, completion: nil)
        
    }

    @IBAction func backShow(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
