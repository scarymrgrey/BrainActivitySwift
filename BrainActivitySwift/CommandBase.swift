//
//  CommandBase.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 20/09/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import RealmSwift
class CommandBase {
    var _realm : RealmSwift.Realm!
    var Realm : RealmSwift.Realm{
        get {
            if _realm == nil {
                _realm = try! RealmSwift.Realm()
            }
            return _realm
        }
        set {}
    }
    final func Execute(_onSuccess : Void -> Void){
        do {
            try Realm.write{
                OnExecute()
                _onSuccess()
            }
        }catch let error{
            OnError(error)
        }
    }
    func OnExecute(){}
    func OnError(error : ErrorType){}
}
