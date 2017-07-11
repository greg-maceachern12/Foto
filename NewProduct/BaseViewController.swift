//
//  BaseViewController.swift
//  AKSwiftSlideMenu
//
//  Created by Ashish on 21/09/15.
//  Copyright (c) 2015 Kode. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class BaseViewController: UIViewController, SlideMenuDelegate {
    
    var dataRef = FIRDatabase.database().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var artistCreate = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        if UserDefaults.standard.bool(forKey: "artistCreate") == true
            {
                self.artistCreate = true
            }
            else
            {
                self.artistCreate = false
            }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
 
        switch(index){
        case 0:
            //print("Artist", terminator: "")
//            
//            let myVCHome = storyboard?.instantiateViewController(withIdentifier: "Home") as! HomeViewController
//            
//            if artistCreate == true{
//                myVCHome.btnInvit.titleLabel?.text = "Recieved \n Invitations"
//                present(myVCHome, animated: true)
//            }
//            else
//            {
//                let alertContoller = UIAlertController(title: "Oops!", message: "You haven't created an Artist Profile yet! Would you like to make one?", preferredStyle: .alert)
//                
//                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
//                    alert -> Void in
//                    
//                    let profVC = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! ViewController
//                    
//                    if profVC.skills == "" || profVC.email == ""{
//                        
//                        let alertContoller2 = UIAlertController(title: "Oops!", message: "You haven't filled out necessary information. \n Go to My Foto and fill out the information", preferredStyle: .alert)
//                        
//                        UserDefaults.standard.removeObject(forKey: "artistOn")
//                    
//                        
//                        let defaultAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
//                        alertContoller2.addAction(defaultAction)
//                        self.present(alertContoller2, animated:true, completion: nil)
//                        
//                        
//                    }
//                    else{
//                        
//                        
//                        let inquirePost: [String : AnyObject] = ["Name": profVC.lblName.text as AnyObject,
//                                                                 "token": self.loggedUser!.uid as AnyObject,
//                                                                 "Rating": Int(0) as AnyObject,
//                                                                 "Skills": profVC.skills as AnyObject,
//                                                                 "Email": profVC.email as AnyObject]
//                        
//                        
////                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Name").setValue(profVC.lblName.text)
////                        
////                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("token").setValue(profVC.user!.uid)
////                        
////                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Rating").setValue("0")
////                        
////                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("skills").setValue(profVC.skills)
////                        
////                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("Email").setValue(profVC.email)
//                        self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).setValue(inquirePost)
//                        
//                        self.dataRef.child("users").child(self.loggedUser!.uid).child("pic").observe(.value){
//                            (snap: FIRDataSnapshot) in
//                            
//                            if snap.exists() == true
//                            {
//                                self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("pic").setValue(snap.value as! String)
//                            }
//                            else{
//                                self.dataRef.child("artistProfiles").child(self.loggedUser!.uid).child("pic").setValue("default.ca")
//                            }
//                        }
//                        UserDefaults.standard.set(true, forKey: "artistCreate")
//                        self.present(profVC, animated: true)
//                        
//                    }
//                    
//                })
//                
//                let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
//                
//                
//                alertContoller.addAction(yesAction)
//                alertContoller.addAction(noAction)
//                self.present(alertContoller, animated:true, completion: nil)
//            }
//            
            
            break
        case 1:
            //print("Play\n", terminator: "")
            
            let myVC = storyboard?.instantiateViewController(withIdentifier: "TableInquire") as! TableInquireViewController
            if artistCreate == true{
                present(myVC, animated: true)
            }
            else
            {
                let alertContoller = UIAlertController(title: "Oops!", message: "You have no inquires! You haven't created an Artist Profile yet! Make one on your home page \n To view your sent inquires, go to your home profile and click more!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertContoller.addAction(defaultAction)
                self.present(alertContoller, animated:true, completion: nil)
            }
            
            
            break
        case 2:
            //            let myVC = storyboard?.instantiateViewController(withIdentifier: "TableInquire") as! TableInquireViewController
            //
            //                present(myVC, animated: true)
            
            //print("yes")
            
            break
        case 3:
            //print("Play\n", terminator: "")
            
            // self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
        case 4:
           // print("Play\n", terminator: "")
            
            // self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
        case 5:
           // print("Play\n", terminator: "")
            
            // self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
        default:
           print("default\n", terminator: "")
        }
    }
    
    func openViewControllerBasedOnIdentifier(_ strIdentifier:String){
        let destViewController : UIViewController = self.storyboard!.instantiateViewController(withIdentifier: strIdentifier)
        
        let topViewController : UIViewController = self.navigationController!.topViewController!
        
        if (topViewController.restorationIdentifier! == destViewController.restorationIdentifier!){
            //print("Same VC")
        } else {
            self.navigationController!.pushViewController(destViewController, animated: true)
        }
    }
    
    func addSlideMenuButton(){
        let btnShowMenu = UIButton(type: UIButtonType.system)
        btnShowMenu.setImage(self.defaultMenuImage(), for: UIControlState())
        btnShowMenu.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btnShowMenu.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        let customBarItem = UIBarButtonItem(customView: btnShowMenu)
        self.navigationItem.leftBarButtonItem = customBarItem;
    }

    func defaultMenuImage() -> UIImage {
        var defaultMenuImage = UIImage()
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 30, height: 22), false, 0.0)
        
        UIColor.black.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 3, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 10, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 17, width: 30, height: 1)).fill()
        
        UIColor.white.setFill()
        UIBezierPath(rect: CGRect(x: 0, y: 4, width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 11,  width: 30, height: 1)).fill()
        UIBezierPath(rect: CGRect(x: 0, y: 18, width: 30, height: 1)).fill()
        
        defaultMenuImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
       
        return defaultMenuImage;
    }
    
    @objc func onSlideMenuButtonPressed(_ sender : UIButton){
        if (sender.tag == 10)
        {
            // To Hide Menu If it already there
            self.slideMenuItemSelectedAtIndex(-1);
            
            sender.tag = 0;
            
            let viewMenuBack : UIView = view.subviews.last!
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                var frameMenu : CGRect = viewMenuBack.frame
                frameMenu.origin.x = -1 * UIScreen.main.bounds.size.width
                viewMenuBack.frame = frameMenu
                viewMenuBack.layoutIfNeeded()
                viewMenuBack.backgroundColor = UIColor.clear
                }, completion: { (finished) -> Void in
                    viewMenuBack.removeFromSuperview()
            })
            
            return
        }
        
        sender.isEnabled = false
        sender.tag = 10
        
        let menuVC : MenuViewController = self.storyboard!.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        menuVC.btnMenu = sender
        menuVC.delegate = self
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
            }, completion:nil)
    }
}
