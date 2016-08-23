//
//  Entity.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 23/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import RealmSwift

class Entity : Object {
    dynamic var Id = NSUUID().UUIDString
    override static func primaryKey() -> String? {
        return "Id"
    }
}