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
    @IBOutlet weak var newHome: UIImageView!
    @IBOutlet weak var lblSent: UILabel!
    @IBOutlet weak var lblFoto: UILabel!
    @IBOutlet weak var imgFoto: UIImageView!
    @IBOutlet weak var imgSent: UIImageView!
    
    var dataRef = FIRDatabase.database().reference()
    var loggedUser = FIRAuth.auth()?.currentUser
    
    var overlay: UIView?
    var overlayAct: UIActivityIndicatorView?
    
    var artistCreate = false
    
    var artistOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnInvit.layer.borderWidth = 0.5
        btnInvit.layer.borderColor = UIColor.lightGray.cgColor
        btnMyFoto.layer.borderWidth = 0.5
        btnMyFoto.layer.borderColor = UIColor.lightGray.cgColor
        
        if UserDefaults.standard.bool(forKey: "artistCreate") == true{
            self.artistCreate = true
        }
        else{
            self.artistCreate = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        //change the layout of the page to display the artist options if artistOn exists
        if UserDefaults.standard.object(forKey: "artistOn") != nil
        {
 
            btnInvit.setImage(#imageLiteral(resourceName: "invitFoto"), for: .normal)
            btnMyFoto.setImage(#imageLiteral(resourceName: "artistFoto1"), for: .normal)
            artistOn = true
        }
    }
    func slideMenuItemSelectedAtIndex(_ index: Int32) {
        
        switch(index){
        case 0:

            break
        case 1:
            let myMessageVC = storyboard?.instantiateViewController(withIdentifier: "TableMess") as! TableMessViewController

            present(myMessageVC, animated: true)
            break
        case 2:
 
            break
        case 3:
          
            break
        case 4:

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
        //open different pages if the artist mode is on
        if artistOn == true{
            let inquireVC : TableInquireViewController = self.storyboard!.instantiateViewController(withIdentifier: "TableInquire") as! TableInquireViewController
            self.present(inquireVC, animated: true)
        }
        else{
            let selfinquireVC : sentInquireViewController = self.storyboard!.instantiateViewController(withIdentifier: "sentInquire") as! sentInquireViewController
            self.present(selfinquireVC, animated: true)
        }
    }
    @IBAction func myFoto(_ sender: Any) {
        
        if artistOn == true{
            let artistVC : ArtistViewController = self.storyboard!.instantiateViewController(withIdentifier: "Artist") as! ArtistViewController
            artistVC.token = self.loggedUser!.uid
            self.present(artistVC, animated: true)
        }
        else{
            overlay = UIView(frame: view.frame)
            overlayAct = UIActivityIndicatorView(frame: CGRect(x: self.view.frame.width/2 - 17, y: self.view.frame.height/2 - 7 , width: 35, height: 35))
            overlay!.backgroundColor = UIColor.black
            overlay!.alpha = 0.8
            overlayAct?.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
    
            view.addSubview(overlay!)
            view.addSubview(overlayAct!)
            overlayAct?.startAnimating()
            let profVC : ViewController = self.storyboard!.instantiateViewController(withIdentifier: "Profile") as! ViewController
            
            self.present(profVC, animated: true, completion: {
                self.overlayAct?.removeFromSuperview()
                self.overlay?.removeFromSuperview()
            })
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
