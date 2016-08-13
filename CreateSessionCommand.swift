import Foundation
import Alamofire
import EVReflection

class CreateSessionCommand: RequestBase {
    
    // MARK: Request Fields
    var PatientId : String?
    var DeviceId : String?
    var Description : String?
    var StartDate : NSDate?
    init() {
        let context = Context(idToken: userDefaults.valueForKey(UserDefaultsKeys.idToken)! as! String, accessToken: userDefaults.valueForKey(UserDefaultsKeys.accessToken)! as!  String,URL : "http://cloudin.incoding.biz/Dispatcher/Query")
        super.init(context: context)
    }
    override func GetParameters() -> [String : AnyObject?] {
        return ["PatienId":PatientId,"StartDate" : StartDate,"Description": Description,"DeviceId":DeviceId,"incTypes":"StartSessionCommand"]
    }
    
    
}