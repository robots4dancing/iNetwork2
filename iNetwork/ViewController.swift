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
    var masterFlavorArray = [Flavor]()
    
    @IBOutlet var flavorTableView       :UITableView!
    @IBOutlet var networkStatusLabel    :UILabel!
    
    //MARK: - Core Methods
    
    func fileInDocumentURL(filename: String) -> URL {
        let docDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("\(docDirectory)")
        return URL(fileURLWithPath: docDirectory).appendingPathComponent(filename)
    }
    
    func fileExistsInDocuments(filename: String) -> Bool {
        let fileDocumentURL = fileInDocumentURL(filename: filename)
        let exists = FileManager.default.fileExists(atPath: fileDocumentURL.path)
        return exists
    }
    
    func imageOnServerURL(filename: String) -> URL {
        let serverString = "http://\(hostName)/classfiles/images"
        return URL(fileURLWithPath: serverString).appendingPathComponent(filename)
    }
    
    func getImage(from: String, to: String, reload: IndexPath) {
        if reachability!.isReachable {
            let fromURL = URL(string: from)!
            let request = URLRequest(url: fromURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let recvData = data else {
                    return
                }
                if recvData.count > 0 && error == nil {
                    if let _ = UIImage(data: recvData) {
                        do {
                            try recvData.write(to: self.fileInDocumentURL(filename: to))
                            DispatchQueue.main.async {
                                self.flavorTableView.reloadRows(at: [reload], with: .automatic)
                            }
                        } catch {
                            print("Error Writing File")
                        }
                    }
                }
            })
            task.resume()
        }
    }
    
    func parseJson(data: Data) {
        do {
            let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any]
            print("JSON:\(jsonResult)")
            let flavorsArray = jsonResult["flavors"] as! [[String:Any]]
            for flavorDictionary in flavorsArray {
                print("Flavor:\(flavorDictionary)")
            }
            masterFlavorArray.removeAll()
            for flavorDictionary in flavorsArray {
                print("Flavor:\(flavorDictionary["name"]!)")
                let id = Int(flavorDictionary["id"] as! String)!
                let name = flavorDictionary["name"] as! String
                let filename = flavorDictionary["filename"] as! String
                let updatedString = flavorDictionary["dateUpdated"] as! String
                let formatter = DateFormatter()
                formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
                let updated = formatter.date(from: updatedString)!
                let newFlavor = Flavor(id: id, name: name, imageName: filename, updated: updated)
                masterFlavorArray.append(newFlavor)
            }
            DispatchQueue.main.async {
                self.flavorTableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
    
    @IBAction func getFilePressed(button: UIBarButtonItem) {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueListToDetail" {
            let indexPath = flavorTableView.indexPathForSelectedRow!
            let currentFlavor = masterFlavorArray[indexPath.row]
            let destVC = segue.destination as! DetailViewController
            destVC.currentFlavor = currentFlavor
            flavorTableView.deselectRow(at: indexPath, animated: true)
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

extension ViewController :UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return masterFlavorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let currentFlavor = masterFlavorArray[indexPath.row]
        cell.textLabel!.text = currentFlavor.flavorName
        if fileExistsInDocuments(filename: currentFlavor.flavorImageFileName) {
            let filename = fileInDocumentURL(filename: currentFlavor.flavorImageFileName).path
            cell.imageView!.image = UIImage(named: filename)
        } else {
            print("Get Image File \(currentFlavor.flavorImageFileName)")
            let imagePath = imageOnServerURL(filename: currentFlavor.flavorImageFileName).absoluteString
            getImage(from: imagePath, to: currentFlavor.flavorImageFileName, reload: indexPath)
        }
        return cell
    }
    
}

