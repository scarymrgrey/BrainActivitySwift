//
//  SDKWrapper.m
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 15/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

#import "SDKWrapper.h"
#import "neuro_sys.h"

//struct BImpl {
//    NeuroSystem* system;
//    int a;
//    BImpl() : system(new NeuroSystem){}
//    ~BImpl() {delete system;system=NULL;}
//};

@implementation SDKWrapper {
    NeuroSystem* eegSystem;
}
-(void)startSystem {
    eegSystem = new NeuroSystem();
}
-(void) destroySystem {
    delete eegSystem;eegSystem = NULL;
}
-(uint16_t) attachDSWith:(sendCommandType)command{
    assert(eegSystem != nil);
    DataSourceInfo info;
    info.type = DS_BRAINBIT;
    info.internal_type_id = 0;
    info.sendCommand = command;
    DS_ID dsid = eegSystem->attachDataSource(info);
    return dsid;
}
@end
