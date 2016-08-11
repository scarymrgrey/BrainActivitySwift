//
//  RealmBase.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 11/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//
import RealmSwift
class RealmBase {
    private var _success : (Void -> Void)!
    private var _error : (Void -> Void)!
    private func execute(_realm : Realm){
        
    }
    func On(success : Void -> Void, error : Void -> Void) {
        _success = success
        _error = error
        let realm = try! Realm()
        execute(realm)
    }
}
	