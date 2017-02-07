//
//  Flavor.swift
//  iNetwork2
//
//  Created by ANI on 2/7/17.
//  Copyright © 2017 Shane Empie. All rights reserved.
//

import UIKit

class Flavor: NSObject {
    
    var flavorID            :Int!
    var flavorName          :String!
    var flavorImageFileName :String!
    var dateUpdated         :Date!
    
    init(id: Int, name: String, imageName: String, updated: Date){
        self.flavorID = id
        self.flavorName = name
        self.flavorImageFileName = imageName
        self.dateUpdated = updated
    }
    
}
