//
//  File.swift
//  testAssignment
//
//  Created by Hiteshi on 21/10/19.
//  Copyright © 2019 demo. All rights reserved.
//

import Foundation


class model {
    var strTitle : String = ""
    var strSubTitle : String = ""
    
    init(dict : [String: Any]) {
        
        self.strTitle = dict["title"] as? String ?? ""
        self.strSubTitle = dict["created_at"] as? String ?? ""
    }
}
