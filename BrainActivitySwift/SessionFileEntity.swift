//
//  SessionFile.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 12/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import RealmSwift

class SessionFileEntity : Object {
    dynamic var Session : SessionEntity?
    dynamic var FileName = ""
    dynamic var Postfix = 0
}
