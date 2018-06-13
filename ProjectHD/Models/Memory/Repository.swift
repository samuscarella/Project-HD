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
    let description: String
    let created_at: Date
    let license: String?
    
}
