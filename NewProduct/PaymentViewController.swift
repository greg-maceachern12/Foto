//
//  PaymentViewController.swift
//  NewProduct
//
//  Created by Greg  MacEachern on 2017-07-12.
//  Copyright © 2017 Greg MacEachern. All rights reserved.





//Currently using paypal as the form of payment but its not finished yet. Considering using stripe instead

import UIKit
//import Stripe


class PaymentViewController: UIViewController,UITextFieldDelegate, PayPalPaymentDelegate {
    
    @IBOutlet weak var tbEmail: UITextField!
    @IBOutlet weak var tbCardNumber: UITextField!
    @IBOutlet weak var tbExpire: UITextField!
    @IBOutlet weak var tbCVC: UITextField!
    @IBOutlet weak var tbAmount: UITextField!
    
    var clientName: String!
    var price: Float!
    
    
    var paypalConfig = PayPalConfiguration()
    
    var environment:String = PayPalEnvironmentNoNetwork {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    var acceptCreditCards: Bool = true {
        didSet{
            paypalConfig.acceptCreditCards = acceptCreditCards
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        paypalConfig.acceptCreditCards = acceptCreditCards
        paypalConfig.merchantName = "SIVA"
        paypalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        paypalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        paypalConfig.languageOrLocale = NSLocale.preferredLanguages[0] 
        paypalConfig.payPalShippingAddressOption = .payPal
        
        PayPalMobile.preconnect(withEnvironment: environment)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
     
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            
        })
    }


    @IBAction func Back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func viewDidAppear(_ animated: Bool) {
        let item1 = PayPalItem(name: clientName, withQuantity: 1, withPrice: NSDecimalNumber(string: "\(price!)"), withCurrency: "USD", withSku: "FOT-001")

        
        let items = [item1]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "\(price! * 0.2)")
        let tax = NSDecimalNumber(string: "\(price! * 0.13)")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "\(clientName!)'s Services", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: paypalConfig, delegate: self)
            present(paymentViewController!, animated: true, completion: nil)
        }
        else {
            // This particular payment will always be processable. If, for
            // example, the amount was negative or the shortDescription was
            // empty, this payment wouldn't be processable
            print("Payment not processalbe: \(payment)")
        }

    }
    @IBAction func payNow(_ sender: Any) {

        
    }

}
