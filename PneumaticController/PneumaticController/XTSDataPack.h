//
//  XTSDataPack.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTSDataPack : NSData

-(UInt8 *)frameHeader;
-(UInt8 *)frameEnd;

@end
