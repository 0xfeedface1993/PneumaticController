//
//  XTSSocketController.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import "XTSDataPack.h"

#define PORT 9600

#define SEND 1
#define RECV 0

@protocol XTSSocketControllerStreamEventErrorOccurredDelegate <NSObject>

-(void)streamEventErrorOccurredAction:(NSError *)error;

@end

@interface XTSSocketController : NSObject<NSStreamDelegate>

@property (nonatomic, assign) int flag;
@property (weak, nonatomic) id<XTSSocketControllerStreamEventErrorOccurredDelegate> errorDelegate;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NSString *  Host_IP;
@property (strong, nonatomic) NSMutableData *recverData;
@property (strong, nonatomic) XTSDataPack *sendData;

-(void)initNetworkCommunication:(NSData *)data hostIP:(NSString * )hostIP;

-(void)close;
-(void)open;

@end

