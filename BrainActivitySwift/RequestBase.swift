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
import AlamofireObjectMapper
import ObjectMapper
class RequestBase {
    // MARK: Locals
    
    private var _context : Context
    private var headers = [String:String]()
    init(context : Context){
        self._context = context
        headers = ["Authorization":"Bearer \(self._context.IdToken) \(self._context.AccessToken)",
                   "Content-Type": "application/json",
                   "Host": "cloudin.incoding.biz",
                   "X-Requested-With": "XMLHttpRequest"
        ]
        print(headers)
    }
    
    // MARK: Public Methods
    
    func GetParameters() -> [String:AnyObject?]{
        return [:]
    }
    func makeRequest(onerror : Void -> Void,onsuccess : (Request,IncResult) -> Void ){
        Alamofire.upload(
            .POST,
            _context.URL,
            headers:  headers,
            multipartFormData: {multipartFormData in
                let propsDict = self.GetParameters()
                for key in propsDict.keys {
                    if let value = propsDict[key]!
                    {
                        if value is NSURL {
                            multipartFormData.appendBodyPart(fileURL: value as! NSURL, name: key)
                        }else {
                            multipartFormData.appendBodyPart(data: value.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                        }
                    }
                }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let request , _,_):
                    request.responseJSON{response in
                        switch response.result{
                        case .Success(let json):
                            print(json)
                            let result = IncResult(_data: json["data"] as! NSObject, _redirectTo: json["redirectTo"] as! String, _statusCode: json["statusCode"] as! Int, _success: json["success"] as! Bool)
                            if (result.success){
                                if(result.statusCode == 200){
                                    onsuccess(request,result)
                                }
                            }else {
                                if(result.data is String){
                                    print(result.data) // here is error
                                }
                                onerror()
                            }
                            break
                        case .Failure(let error):
                            print(error)
                            break
                        }
                    }
                    break
                case .Failure(let error):
                    print(error)
                }
        })
    }
    
    func On(success success : String -> Void,error :Void -> Void){
        makeRequest(error){ (request,incRes) in
            success(incRes.data as! String)
        }
    }
    
    func On<T : Mappable>(success success : T -> Void,error :Void -> Void){
        makeRequest(error){ (request ,incRes) in
            let result = T(JSONString : incRes.data as! String)
            success(result!)
            //self.responseObject(upload, success: success)
        }
    }
    
    func On<T : SequenceType where T.Generator.Element : Mappable>(success success : T -> Void,error :Void -> Void){
        makeRequest(error){ (request ,incRes) in
            self.responseArray(request, success: success)
        }
    }
    
    //    func responseJSON(request : Request,success : IncResult -> Void) {
    //        request.responseJSON{ (response) in
    //            switch response.result{
    //            case .Success(let json):
    //                let result = IncResult(_data: json["data"] as! String, _redirectTo: json["redirectTo"] as! String, _statusCode: json["statusCode"] as! Int, _success: json["success"] as! Bool)
    //                success(result)
    //                break
    //            case .Failure(let error):
    //                print(error)
    //                break
    //            }
    //        }
    //    }
    
    //    func responseObject<T : Mappable>(request : Request,success : T -> Void) {
    //        request.responseObject(keyPath: "data",completionHandler: { (response : Response<T, NSError>) in
    //                switch response.result{
    //                case .Success(let rawData):
    //                    success(rawData)
    //                    break
    //                case .Failure(let error):
    //                    print(error)
    //                    break
    //                }
    //            })
    //    }
    
    func responseArray<T : SequenceType where T.Generator.Element : Mappable>(request : Request,success : T -> Void){
        request.responseArray(keyPath: "data",completionHandler: { (response : Response<[T.Generator.Element], NSError>) in
            switch response.result{
            case .Success(let rawData):
                success(rawData as! T)
                break
            case .Failure(let error):
                print(error)
                break
            }
        })
    }
}
