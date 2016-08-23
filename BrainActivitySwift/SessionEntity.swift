//
//  Session.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 23/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import RealmSwift

class SessionEntity : Entity {
    var Files = List<SessionFileEntity>()
    var Activities = List<ActivityEntity>()
}
