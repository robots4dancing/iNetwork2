//
//  DetailViewViewController.swift
//  iNetwork2
//
//  Created by ANI on 2/7/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit
import MessageUI
import Social

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var currentFlavor :Flavor!
    
    //MARK: - Interactivity Methods
    
    @IBAction func shareOnEmail(button: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setSubject("I LOVE \(currentFlavor.flavorName) ICE CREAM")
            mailVC.setMessageBody("Yes, I do love \(currentFlavor.flavorName)", isHTML: false)
            mailVC.setToRecipients(["sempie@wccnet.edu"])
            present(mailVC, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareOnSMS(button: UIButton) {
        if MFMessageComposeViewController.canSendText() {
            let msgVC = MFMessageComposeViewController()
            msgVC.messageComposeDelegate = self
            msgVC.body = "I LOVE \(currentFlavor.flavorName) ICE CREAM"
            present(msgVC, animated: true, completion: nil)
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.becomeFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareOnFacebook(button: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
            fbVC.setInitialText("I LOVE \(currentFlavor.flavorName) ICE CREAM")
            present(fbVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareOnTwitter(button: UIButton) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let twVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            twVC.setInitialText("I LOVE \(currentFlavor.flavorName) ICE CREAM")
            present(twVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func shareOnWhatever(button: UIButton) {
        let shareString = "I LOVE \(currentFlavor.flavorName) ICE CREAM"
        let activityVC = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    
    //MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Got \(currentFlavor.flavorName)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
