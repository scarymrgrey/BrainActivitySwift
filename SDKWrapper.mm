//
//  SDKWrapper.m
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 15/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

#import "SDKWrapper.h"
#import "neuro_sys.h"
#define testAsset(condition) if(!(condition)){ *error = [[NSError alloc] initWithDomain:@"#condition" code:0 userInfo:nil]; return nil; }




//struct BImpl {
//    NeuroSystem* system;
//    int a;
//    BImpl() : system(new NeuroSystem){}
//    ~BImpl() {delete system;system=NULL;}
//};

@interface SDKWrapper()

@end

@implementation SDKWrapper
    NeuroSystem* eegSystem;



-(void)startSystem {
    eegSystem = new NeuroSystem();
}

-(void) destroySystem {
    delete eegSystem;eegSystem = NULL;
}

-(NSNumber*) attachDS:(sendCommandType)command error:(__autoreleasing NSError**)error;{
    testAsset(eegSystem != nil)
    
    DataSourceInfo info;
    info.type = DS_BRAINBIT;
    info.internal_type_id = 0;
    info.sendCommand = command;
    DS_ID dsid = eegSystem->attachDataSource(info);
    return [[NSNumber alloc] initWithUnsignedShort: dsid];
}
@end
