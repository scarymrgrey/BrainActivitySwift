//
//  SDKWrapper.h
//  BrainActivitySwift
//
//  Created by Kirill Polunin on 15/11/2016.
//  Copyright © 2016 Kirill Polunin. All rights reserved.
//

#import <Foundation/Foundation.h>
//struct BImpl;
//@interface SDKWrapper : NSObject
//@property struct BImpl* impl;
//@end
typedef void (*sendCommandType) (uint8_t device_type, char* command, size_t size);

@interface SDKWrapper : NSObject
-(void) startSystem;
-(void) destroySystem;
-(uint16_t) attachDSWith:(sendCommandType)command;
@end
