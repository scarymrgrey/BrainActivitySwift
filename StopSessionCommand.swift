//
//  StopSessionCommand.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 20/09/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation

class StopSessionCommand : CommandBase{
    var SessionId : String!
    var Duration : Int!
    override func OnExecute() {
        let targetSession = Realm.objects(SessionEntity).filter("Id == \(SessionId)").first!
           targetSession.Duration = Duration 
        
    }
    override func OnError(error : ErrorType) {
        print(error)
    }
}
