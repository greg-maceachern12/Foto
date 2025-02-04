//
//  inquireViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-09.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase

class inquireViewController: UIViewController, UIBarPositioningDelegate {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblStart: UILabel!
    @IBOutlet weak var lblEnd: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var navTitle: UILabel!
    
    @IBOutlet weak var imgprof: UIImageView!
    @IBOutlet weak var Loader: UIActivityIndicatorView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    @IBOutlet weak var Pricing: UILabel!
    @IBOutlet weak var lblTheme: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    var loggedUser = FIRAuth.auth()?.currentUser
    var dataRef = FIRDatabase.database().reference()
    
    var code: String!
    var token: String!
    var clientEmail: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        SetUp()
        uploadPic()
        
        btnAccept.applyGradient(colours: [UIColor(red: 0, green: 145/255, blue: 1, alpha: 1.0), UIColor(red: 0, green: 97/255, blue: 1, alpha: 1.0)])
        
        btnDecline.applyGradient(colours: [UIColor(red: 255/255, green: 21/255, blue: 0, alpha: 1.0), UIColor(red: 226/255, green: 0, blue: 10/255, alpha: 1.0)])
    
    }
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func SetUp(){
        imgprof.layer.cornerRadius = imgprof.frame.width/8
        imgprof.clipsToBounds = true
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("ClientName").observe(.value){
            (snap: FIRDataSnapshot) in
            self.navTitle.text = "\(snap.value as! String)'s Inquiry"
            self.lblName.text = snap.value as? String
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("ClientEmail").observe(.value){
            (snap: FIRDataSnapshot) in
            self.clientEmail = snap.value as? String
    
        }
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("Theme").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblTheme.text = snap.value as? String
        }
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("PricingOption").observe(.value){
            (snap: FIRDataSnapshot) in
            self.Pricing.text = snap.value as? String
        }
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("PriceOption").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblPrice.text = "$\(snap.value as! Float)"
        }
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("StartDate").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblStart.text = "Start: \(snap.value as! String)"
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("EndDate").observe(.value){
            (snap: FIRDataSnapshot) in
            self.lblEnd.text = "End: \(snap.value as! String)"
        }
        
        dataRef.child("artistProfiles").child(loggedUser!.uid).child("Inquires").child(code).child("ExtraNotes").observe(.value){
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
        let alertContoller = UIAlertController(title: "Confirm!", message: "Are You Sure You Want To Decline This Inquiry?", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            
            let alertContoller2 = UIAlertController(title: "Success!", message: "You Successfully Declined This Inquiry", preferredStyle: .alert)
            let defaultAction2 = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            alertContoller2.addAction(defaultAction2)
            self.dataRef.child("users").child(self.token).child("Sent Inquires").child(self.code).child("Status").setValue("Declined")
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Inquires").child(self.code).child("Status").setValue("Declined")
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
            self.present(myVC, animated: true)
            self.present(alertContoller2, animated:true, completion: nil)
        })
    
        alertContoller.addAction(yesAction)
        alertContoller.addAction(defaultAction)
        
        self.present(alertContoller, animated:true, completion: nil)
    }
    
    //the action for the accept button.
    @IBAction func Accept(_ sender: Any) {
        
        let alertContoller = UIAlertController(title: "Confirm!", message: "Are You Sure You Want To Accept This Inquiry?", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            alert -> Void in
            
            self.lblEmail.text = self.clientEmail
            self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Inquires").child(self.code).child("Status").setValue("Accepted")
            self.dataRef.child("users").child(self.token).child("Sent Inquires").child(self.code).child("Status").setValue("Accepted")
            let myVC = self.storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
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
