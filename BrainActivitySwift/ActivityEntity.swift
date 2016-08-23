//
//  SessionType.swift
//  BrainActivitySwift
//
//  Created by Victor Gelmutdinov on 23/08/16.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

import Foundation
import RealmSwift
enum ActivityTypeEnum : String{
    case Biking = "activity-biking"
    case Cooking = "activity-cooking"
    case Dating = "activity-dating"
    case Driving = "activity-driving"
    case Gaming = "activity-gaming"
    case Meditation = "activity-meditation"
    case Movies = "activity-movies"
    case Other = "activity-other"
    case Reading = "activity-reading"
    case Working = "activity-working"
    
}
class ActivityEntity : Entity {
    dynamic var activityType = ActivityTypeEnum.Biking.rawValue
    var ActivityEnum : ActivityTypeEnum {
        get {
            return ActivityTypeEnum(rawValue: activityType)!
        }
        set{
            activityType = newValue.rawValue
        }
    }
    dynamic var StartsFrom = 0
}