//
//  ViewController.swift
//  iNetwork
//
//  Created by ANI on 1/31/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let hostName = "www.moveablebytes.com"
    var reachability :Reachability?
    
    @IBOutlet var networkStatusLabel :UILabel!
    
    //MARK: - Reachability Methods
    
    func setupReachability(hostName: String) {
        reachability = Reachability(hostname: hostName)
        reachability!.whenReachable = { reachability in
            DispatchQueue.main.async {
                self.updatedLabel(reachable: true, reachability: reachability)
            }
        }
        reachability!.whenUnreachable = { reachability in
            
        }
    }
    
    func startReachability() {
        do {
            try reachability!.startNotifier()
        } catch {
            networkStatusLabel.text = "Unable to Start Notifier"
            networkStatusLabel.textColor = .red
            return
        }
    }
    
    func updatedLabel(reachable: Bool, reachability: Reachability) {
        if reachable {
            if reachability.isReachableViaWiFi {
                networkStatusLabel.textColor = .green
            } else {
                networkStatusLabel.textColor = .blue
            }
        } else {
            networkStatusLabel.textColor = .red
        }
        networkStatusLabel.text = reachability.currentReachabilityString
    }
    
    //MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupReachability(hostName: hostName)
        startReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

