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
//#import "XTSDataPack.h"

#define PORT 9600

#define SEND 1
#define RECV 0

static NSString *HOST_IP = @"10.88.132.125";

typedef NS_ENUM(NSInteger,XTSDataMode){
  XTSDataAutoMode,
  XTSDataManuelMode,
  XTSDataStateRequireMode,
  XTSDataPhotoMode
};

@protocol XTSSocketControllerStreamEventErrorOccurredDelegate <NSObject>

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type;
-(void)streamEventOpenSucces;
-(void)streamEventClose;

@end

@protocol XTSSocketControllerStreamEventDataProcessDelegate <NSObject>
-(void)streamDataRecvSuccess:(NSData *)data;
@end


@interface XTSSocketController : NSObject<NSStreamDelegate>

@property (nonatomic, assign) int flag;
@property (weak, nonatomic) id<XTSSocketControllerStreamEventErrorOccurredDelegate> errorDelegate;
@property (weak, nonatomic) id<XTSSocketControllerStreamEventDataProcessDelegate> dataDelegate;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NSMutableData *recverData;
@property (strong, nonatomic) NSMutableData *sendData;

-(void)initNetworkCommunication:(NSDictionary *)data hostIP:(NSString * )hostIP port:(NSString *)port;
-(BOOL)sendDataWithMode:(XTSDataMode)mode dataPack:(NSDictionary *)data;
-(BOOL)getInfomation;

-(NSDictionary *)packSendData:(id)data WithMode:(XTSDataMode)mode;

-(void)close;
-(void)open;

@end


