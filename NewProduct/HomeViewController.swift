//
//  HomeViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-06-13.
//  Copyright © 2017 Greg MacEachern. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, SlideMenuDelegate {
    
    @IBOutlet weak var btnSlide: UIButton!
    @IBOutlet weak var btnMyFoto: UIButton!
    @IBOutlet weak var btnFindArtist: UIButton!
    @IBOutlet weak var btnInvit: UIButton!

    var dataRef = FIRDatabase.database().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var artistCreate = false
    
    var artistOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //btnInvit.applyDesign()
        btnFindArtist.applyDesign()
        btnMyFoto.applyDesign()
        
            if UserDefaults.standard.bool(forKey: "artistCreate") == true
            {
                self.artistCreate = true
            }
            else
            {
                self.artistCreate = false
            }
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "artistOn") != nil
        {
            btnInvit.setImage(#imageLiteral(resourceName: "invitFoto"), for: .normal)
            btnFindArtist.setImage(#imageLiteral(resourceName: "findFoto"), for: .normal)
            btnMyFoto.setImage(#imageLiteral(resourceName: "artistFoto1"), for: .normal)
       // btnInvit.setTitle("   RECIEVED\nINVITATIONS", for: .normal)
            artistOn = true
            
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        
        //let topViewController : UIViewController = self.navigationController!.topViewController!
        //print("View Controller is : \(topViewController) \n", terminator: "")
        switch(index){
        case 0:
            //print("Artist", terminator: "")
            
            
            
            break
        case 1:
           // print("Play\n", terminator: "")
            
//            let myVC = storyboard?.instantiateViewController(withIdentifier: "TableInquire") as! TableInquireViewController
//            if artistCreate == true{
//                present(myVC, animated: true)
//            }
//            else
//            {
//                let alertContoller = UIAlertController(title: "Oops!", message: "You have no inquires! You haven't created an Artist Profile yet! Make one on your home page \n To view your sent inquires, go to your home profile and click more!", preferredStyle: .alert)
//                
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertContoller.addAction(defaultAction)
//                self.present(alertContoller, animated:true, completion: nil)
            //}
            let myMessageVC = storyboard?.instantiateViewController(withIdentifier: "TableMess") as! TableMessViewController
            
            
            
            present(myMessageVC, animated: true)
            
            
            
            break
        case 2:
            
         
            
          
            
            break
        case 3:
          
            break
        case 4:
           // print("Play\n", terminator: "")
            
            // self.openViewControllerBasedOnIdentifier("PlayVC")
            
            break
    
        default:
            print("default\n", terminator: "")
        }
    }
    

    
    
    @IBAction func SliderClick(_ sender: UIButton) {
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
        if artistOn == true{
            menuVC.artistOn = true
        }
        self.view.addSubview(menuVC.view)
        self.addChildViewController(menuVC)
        menuVC.view.layoutIfNeeded()
        
        
        menuVC.view.frame=CGRect(x: 0 - UIScreen.main.bounds.size.width, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            menuVC.view.frame=CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height);
            sender.isEnabled = true
        }, completion:nil)
    }
    
    @IBAction func invitAction(_ sender: Any) {
        
        if artistOn == true
        {
            let inquireVC : TableInquireViewController = self.storyboard!.instantiateViewController(withIdentifier: "TableInquire") as! TableInquireViewController
            
            self.present(inquireVC, animated: true)
        }
        else
        {
            let selfinquireVC : sentInquireViewController = self.storyboard!.instantiateViewController(withIdentifier: "sentInquire") as! sentInquireViewController
            
            self.present(selfinquireVC, animated: true)
        }
    }
    @IBAction func myFoto(_ sender: Any) {
        
        if artistOn == true
        {
            let artistVC : ArtistViewController = self.storyboard!.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController
            
            artistVC.token = self.loggedUser!.uid
            
            self.present(artistVC, animated: true)
        }
        else
        {
            let profVC : ViewController = self.storyboard!.instantiateViewController(withIdentifier: "Profile") as! ViewController
            
            self.present(profVC, animated: true)
        }
        
    }
    
    
}

extension UIButton{
    
    func applyDesign(){
    self.layer.shadowColor = UIColor.lightGray.cgColor
    self.layer.shadowOffset = CGSize(width: 0, height: 9)
    self.layer.shadowOpacity = 1.0
    self.layer.shadowRadius = 0.0
    self.layer.masksToBounds = false
    self.layer.cornerRadius = 4.0
    }
}
