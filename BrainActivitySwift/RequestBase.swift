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
protocol Initializable {
    init()
}
extension String : Initializable{
    
}
class RequestBase <TResponse : Initializable> {
    // MARK: Locals
    private var _success : (TResponse -> Void)!
    private var _successWithCollection : (Array<TResponse> -> Void)!
    private var _error : (Void -> Void)!
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
    
    func On(success success : TResponse -> Void,error :Void -> Void){
        _success = success
        _error = error
        self.Execute()
    }
    func On(success success : Array<TResponse> -> Void,error :Void -> Void){
        _successWithCollection = success
        _error = error
        self.Execute()
    }
    func GetParameters() -> [String:AnyObject?]{
        return [:]
    }
    func Execute(){
        Alamofire.upload(
            .POST,
            _context.URL,
            headers:  headers,
            multipartFormData: { multipartFormData in
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
                    upload.responseObject(completionHandler: { (response : Response<GetSessionsQueryResponse2, NSError>) in
                        print(response.response)
                    })
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result{
                        case .Success(let rawData):
                            
                            if (rawData["success"] as! Bool){
                                if TResponse() is EVObject{
                                    if rawData["data"]! is NSArray {
                                        var response = Array<TResponse>()
                                        for elem in (rawData["data"]! as! NSArray){
                                            let responseData = TResponse()
                                            let dict = elem as! NSDictionary
                                            EVReflection.setPropertiesfromDictionary(dict , anyObject: responseData as! EVObject, conversionOptions: .DefaultDeserialize)
                                            response.append(responseData)
                                        }
                                        self._successWithCollection(response)
                                    }else {
                                        let response = TResponse()
                                        EVReflection.setPropertiesfromDictionary(rawData["data"]! as! NSDictionary, anyObject: response as! EVObject, conversionOptions: .DefaultDeserialize)
                                        self._success(response)
                                    }
                                }else {
                                    self._success(rawData["data"]! as! TResponse)
                                }
                                
                            }else {
                                print(rawData)
                            }
                            break
                        case .Failure(let error):
                            print(error)
                            break
                        }
                    })
                    break
                case .Failure(let error):
                    print(error)
                }
        })
    }
}