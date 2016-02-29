//
//  XTSSocketController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSSocketController.h"

@interface XTSSocketController()
@property(nonatomic,assign)BOOL ConnectOverTimer;
@property(nonatomic,assign)double delayTime;
@property(nonatomic,assign)BOOL isFirstFourBytes;
@property(nonatomic,assign)UInt32 remainingToRead;
@end



@implementation XTSSocketController

-(void)initNetworkCommunication:(NSDictionary *)data  hostIP:(NSString * )hostIP{
    self.Host_IP = hostIP;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.Host_IP, 6002,&readStream, &writeStream);
    
    
    _inputStream = (__bridge_transfer NSStream *)readStream;
    _outputStream = (__bridge_transfer NSStream *)writeStream;
    
    //NSStrea
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    
    _ConnectOverTimer = YES;
    _delayTime = 5.0;
    _isFirstFourBytes = YES;
    self.flag = RECV;
    [self performSelector:@selector(checkConnectOverTime) withObject:nil afterDelay:_delayTime];
}
/*
- (void)SetDelayOverTime:(double)connectTime
{
    _delayTime = connectTime;
}
*/
-(BOOL)sendDataWithMode:(XTSDataMode)mode dataPack:(NSDictionary *)data{
    NSDictionary *jsonDictionary;
    NSError *error_json;
    NSData *postData;
    NSMutableData *allData;
    UInt32 dataLenthg;
    
    switch (mode) {
        case XTSDataAutoMode:
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"auto",nil];
            break;
        case XTSDataManuelMode:
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"hand",nil];
            break;
        case XTSDataStateRequireMode:
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"ok",@"state",nil];
            break;
        case XTSDataPhotoMode:
            jsonDictionary = data;
            break;
        default:
            break;
    }
    
    if ([NSJSONSerialization isValidJSONObject:jsonDictionary]) {
        postData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error_json];
        dataLenthg = [postData length];
        allData = [[NSMutableData alloc] initWithBytes:&dataLenthg length:sizeof(UInt32)];
        [allData appendData: postData];
        NSLog(@"send data: %@", allData);
        self.sendData = allData;
        self.flag = SEND;
        
        return YES;
    }
    
    return NO;
}
/*
-(void)setSendData:(XTSDataPack *)sendData{
    if (sendData!=nil) {
        _sendData=sendData;
    }
}*/

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
     NSString *event;
    switch (eventCode) {
            
        case NSStreamEventNone:
            event=@"NSStreamEventNone";
            break;
            
        case NSStreamEventOpenCompleted:
            event=@"NSStreamEventOpenCompleted";
            
            [self.errorDelegate streamEventOpenSucces];
            break;
            
        case NSStreamEventHasBytesAvailable:
            event=@"NSStreamEventHasBytesAvailable";
            if(_isFirstFourBytes)//读取前4个字节，算出数据包大小
            {
                uint8_t bufferLen[4];
                if([_inputStream read:bufferLen maxLength:4] == 4)
                {
                    NSLog(@"4 bytes: %x %x %x %x",bufferLen[0],bufferLen[1],bufferLen[2],bufferLen[3]);
                    _remainingToRead = ((bufferLen[3]<<24)&0xff000000)+((bufferLen[2]<<16)&0xff0000)+((bufferLen[1]<<8)&0xff00)+(bufferLen[0] & 0xff);
                    _isFirstFourBytes = NO;
                }
                else
                {
                    [self close];
                    //Error Control
                }
            }else{
                uint8_t buffer[32768];
                int len = 32768;
                if (self.recverData == nil) {
                    self.recverData = [[NSMutableData alloc] init];
                }
                int actuallyRead;
                actuallyRead = [_inputStream read:buffer maxLength:sizeof(buffer)];
                if(actuallyRead == -1){
                    [self close];
                    //Error Control
                }else if(actuallyRead == 0){
                    //Do something if you want
                }else{
                    [self.recverData appendBytes:buffer length:actuallyRead];
                    _remainingToRead -= actuallyRead;
                    NSLog(@"recve data %s", buffer);
                }
                    
                if(_remainingToRead == 0)
                {
                    [self.dataDelegate streamDataRecvSuccess:self.recverData];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                        NSLog(@"rev data : %@", self.recverData);
                    });
                    _isFirstFourBytes = YES;
                    self.recverData = nil;
                }
            }
            
        case NSStreamEventHasSpaceAvailable:
            event=@"NSStreamEventHasSpaceAvailable";
            /*
            if (_flag==SEND&&aStream==_outputStream&&_sendData!=nil) {
                NSUInteger bytesLength=[self.sendData length];
                uint8_t *buffer=malloc(bytesLength);
                [_outputStream write:[self.sendData bytes] maxLength:bytesLength];
                [_outputStream close];
                free(buffer);
            }
             */
            [self canclCheckConnectOverTimer];
            
            if (self.flag == SEND) {
                //uint8_t *sendbuf;
                NSInteger left = [self.sendData length];
                int count = 0;
                const int MaxSend = 32*1024;
                while(left > 0)
                {
                    if ([_outputStream hasSpaceAvailable] == NO) //如果发送缓存已满，暂停0。1秒
                    {
                        NSLog(@"outputStream buffer full!");
                        [NSThread sleepForTimeInterval:0.1];
                        continue;
                    }
                    int n = 0;
                    //每次32kb的发送，不足32kb，全部发送
                    
                    if (left<MaxSend)
                    {
                        n = [_outputStream write:[self.sendData bytes] maxLength:left];
                    }
                    else
                    {
                        n = [_outputStream write:[self.sendData bytes] maxLength:MaxSend];
                    }
                    
                    if (n <= 0) //这地方会不会导致图片发送不完整
                    {
                        // break;
                    }
                    
                    count += n;
                    left -= n;
                }
                self.flag = RECV;
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            event=@"NSStreamEventErrorOccurred";
            [_errorDelegate streamEventErrorOccurredAction:[aStream streamError]  type:event];
            [self close];
            break;
            
        case NSStreamEventEndEncountered:
            event=@"NSStreamEventEndEncountered";
            //[_errorDelegate streamEventErrorOccurredAction:[aStream streamError]  type:event];
            [self close];
            break;
            
        default:
            break;
    }
}

-(BOOL)getInfomation{
    return YES;
}
//检查连接超时
- (void)checkConnectOverTime
{
    if (_ConnectOverTimer)
    {
        _ConnectOverTimer = NO;
        [self close];
        
        //connect overTime
        [self NetEventConnectOverTime];
    }
}

-(void)NetEventConnectOverTime{
    [_errorDelegate streamEventErrorOccurredAction:nil type:@"NetEventConnectOverTime"];
}

- (void)canclCheckConnectOverTimer
{
    _ConnectOverTimer = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkConnectOverTime) object:nil];
}

-(void)close{
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    [self.errorDelegate streamEventClose];
}

-(void)open{
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}

#pragma mark - Pack Data Method

-(NSDictionary *)packSendData:(id)data WithMode:(XTSDataMode)mode{
    NSMutableDictionary *keysAndValues=[[NSMutableDictionary alloc] init];;
    NSDictionary *jsonDictionary;
    switch (mode) {
        case XTSDataAutoMode: {
            NSMutableArray *arry=data;
            for (NSDictionary *set in arry) {
                NSNumber *number=[set valueForKey:@"number"];
                NSNumber *pressure=[set valueForKey:@"pressure"];
                NSNumber *timeout=[set valueForKey:@"time"];
                NSString *numberKey=[NSString stringWithFormat:@"item%d",[number intValue]];
                [keysAndValues setObject:[NSDictionary dictionaryWithObjectsAndKeys:pressure,@"pressure",timeout,@"timeout", nil] forKey:numberKey];
            }
            jsonDictionary=[NSDictionary dictionaryWithObjectsAndKeys:keysAndValues,@"auto",nil];
            break;
        }
        case XTSDataManuelMode: {
            keysAndValues=data;
            jsonDictionary=[NSDictionary dictionaryWithObjectsAndKeys:keysAndValues,@"hand",nil];
            break;
        }
        case XTSDataStateRequireMode: {
            jsonDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"ok",@"state", nil];
            break;
        }
        case XTSDataPhotoMode: {
            jsonDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"photo",@"photo", nil];
            break;
        }
            
    }
    return jsonDictionary;
}

@end
