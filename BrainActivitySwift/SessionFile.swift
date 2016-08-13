//
//  SessionFile.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 12/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import RealmSwift

class SessionFile : Object {
    
    dynamic var SessionId = ""
    dynamic var FileName = ""
    dynamic var Postfix = 0
    
// Specify properties to ignore (Realm won't persist these)
    
  //override static func ignoredProperties() -> [String] {
 //   return []
  //}
}
