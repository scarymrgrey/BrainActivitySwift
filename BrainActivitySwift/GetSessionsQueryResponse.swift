//
//  GetSessionsResponse.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 10/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//
import EVReflection
import Realm
import ObjectMapper
class GetSessionsQueryResponse : EVObject , Initializable {
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
class GetSessionsQueryResponse2 : Mappable {
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
    required init?(_ map: Map){
        
    }
    
    func mapping(map: Map) {
        Id <- map["Id"]
        Type <- map["Type"]
    }
}