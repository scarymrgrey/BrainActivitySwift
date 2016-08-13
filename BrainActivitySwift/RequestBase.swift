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
    }
    
    // MARK: Public Methods
    
    func GetParameters() -> [String:AnyObject?]{
        return [:]
    }
    

    func makeRequest(mapper : Request -> Void ){
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
                case .Success(let upload , _ ,_):
                    mapper(upload)
                    break
                case .Failure(let error):
                    print(error)
                }
        })

    }
    func On(success success : String -> Void,error :Void -> Void){
        makeRequest{ (upload) in
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .Success(let rawData):
                            if (rawData["success"] as! Bool){
                                    success(rawData["data"]! as! String)
                            }else {
                                print(rawData)
                            }
                            break
                        case .Failure(let error):
                            print(error)
                            break
                        }
                    })
        }
    }
    func On<T : Mappable>(success success : T -> Void,error :Void -> Void){
        makeRequest{ (upload) in
            upload.responseObject(keyPath: "data",completionHandler: { (response : Response<T, NSError>) in
                switch response.result{
                case .Success(let rawData):
                        success(rawData)
                    break
                case .Failure(let error):
                    print(error)
                    break
                }
            })
        }
    }
   

    func On<T : SequenceType where T.Generator.Element : Mappable>(success success : T -> Void,error :Void -> Void){
        makeRequest{ (upload) in
            upload.responseArray(keyPath: "data",completionHandler: { (response : Response<[T.Generator.Element], NSError>) in
                switch response.result{
                case .Success(let rawData):
                    print(rawData as! T)
                    success(rawData as! T)
                    break
                case .Failure(let error):
                    print(error)
                    break
                }
            })
        }
    }

}