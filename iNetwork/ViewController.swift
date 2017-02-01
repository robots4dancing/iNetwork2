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
    
    //MARK: - Core Methods
    
    func parseJson(data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print("JSON:\(jsonResult)")
            let flavorsArray = jsonResult["flavors"] as! [[String:Any]]
            for flavorDictionary in flavorsArray {
                print("Flavor:\(flavorDictionary)")
            }
            for flavorDictionary in flavorsArray {
                print("Flavor:\(flavorDictionary["name"]!)")
            }
        } catch {
            print("JSON Parsing Error")
        }
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
    }
    
    func getFile(filename: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let urlString = "http://\(hostName)\(filename)"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let receivedData = data else {
                print("No Data")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
            }
            if receivedData.count > 0 && error == nil {
                print("Received Data:\(receivedData)")
                let dataString = String.init(data: receivedData, encoding: .utf8)
                print("Got Data String:\(dataString!)")
                self.parseJson(data: receivedData)
            } else {
                print("Got Data of Length 0")
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        task.resume()
    }
    
    //MARK: - Interactivity Methods
    
    @IBAction func getFilePressed(button: UIButton) {
        guard let reach = reachability else {
            return
        }
        if reach.isReachable {
            //getFile(filename: "/classfiles/iOS_URL_Class_Get_File.txt")
            getFile(filename: "/classfiles/flavors.json")
        } else {
            print("Host Not Reachable. Turn on the Internet")
        }

    }
    
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

