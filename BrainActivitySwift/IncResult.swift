//
//  CloudBaseResponse.swift
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 27/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import EVReflection
import Realm
import ObjectMapper
import RealmSwift
class IncResult {
    var  data : NSObject
    var  redirectTo: String
    var  statusCode: Int
    var  success : Bool
    init(_data : NSObject,_redirectTo : String, _statusCode : Int,_success : Bool) {
        data = _data
        redirectTo = _redirectTo
        statusCode = _statusCode
        success = _success
    }
}
