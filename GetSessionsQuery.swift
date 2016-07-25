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
class GetSessionsQueryResponse : EVObject , Initializable{
    var  Id : String!
    var  StartDate: String!
    var  EndDate: String!
    var  Description: String!
    var  Type: String!
    var  Patient: String!
    var  Owner: String!
    var  CountOfFiles: String!
    var  SizeOfFIles: String!
    var  IsStart: String!
    var  IsClose: String!
}
class GetSessionsQuery<TResponse : Initializable>  :  RequestBase <TResponse > {
    // MARK: Request Fields
    
    var Mime : String?
    var SessionId : String!
    var Body : NSURL?
    
    // MARK: Public Methods
    
    override init(context: Context) {
        super.init(context: context)
    }
    override func GetParameters() -> [String:AnyObject?]{
        return ["incTypes":"GetSessionsQuery"]
    }
}