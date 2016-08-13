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
import RealmSwift
class GetSessionsQueryResponse : Object,Mappable{
    dynamic var  Id : String! = ""
    dynamic var  StartDate: String! = ""
    dynamic var  EndDate: String! = ""
    dynamic var  Description: String! = ""
    dynamic var  Type: String! = ""
    dynamic var  Patient: String! = ""
    dynamic var  Owner: String! = ""
    dynamic var  CountOfFiles: String! = ""
    dynamic var  SizeOfFIles: String! = ""
    dynamic var  IsStart: String! = ""
    dynamic var  IsClose: String! = ""
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        Id <- map["Id"]
        StartDate <- map["StartDate"]
        EndDate <- map["EndDate"]
        Description <- map["Description"]
        Type <- map["Type"]
        Patient <- map["Patient"]
        Owner <- map["Owner"]
        CountOfFiles <- map["CountOfFiles"]
        SizeOfFIles <- map["SizeOfFIles"]
        IsStart <- map["IsStart"]
        IsClose <- map["IsClose"]
    }
}

