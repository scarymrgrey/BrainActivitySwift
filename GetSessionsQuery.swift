//
//  File.swift
//  Auth0Example
//
//  Created by Kirill Polunin  on 12/07/16.
//  Copyright © 2016 Victor Gelmutdinov. All rights reserved.
//

import Foundation
import Alamofire
import EVReflection

class GetSessionsQuery  :  RequestBase {
    // MARK: Request Fields
    
    var Mime : String?
    var SessionId : String!
    var Body : NSURL?
    
    // MARK: Public Methods
    
    override init(context: Context) {
        super.init(context: context)
    }
    override func GetParameters() -> [String:AnyObject?]{
        return ["incType":"GetSessionsQuery"]
    }
}
