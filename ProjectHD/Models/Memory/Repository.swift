//
//  Repository.swift
//  ProjectHD
//
//  Created by Stephen Muscarella on 6/13/18.
//  Copyright © 2018 Elite Development. All rights reserved.
//

import Foundation

class Repository: Decodable {
    
    let name: String
    let created_at: String
    let description: String?
    let license: String?
    
    init(json: [String:Any]) {
        
        name = json["name"] as! String
        description = json["description"] as? String
        created_at = json["created_at"] as! String
        license = json["license"] as? String
    }
    
}
