//
//  XTSSocketController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSSocketController.h"
#import "NSStreamAdditions.h"

const int MaxSend = 32 * 1024;

@interface XTSSocketController()
@property (nonatomic, assign) BOOL ConnectOverTimer;
@property (nonatomic, assign) double delayTime;
@property (nonatomic, assign) BOOL isFirstFourBytes;
@property (nonatomic, assign) UInt32 remainingToRead;
@property (nonatomic, strong) NSString *hostIP;
@property (nonatomic, strong) NSString *port;
@end

@implementation XTSSocketController

-(void)initNetworkCommunication:(NSDictionary *)data hostIP:(NSString * )hostIP port:(NSString *)port {
    self.hostIP = hostIP;
    self.port = port;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)self.hostIP, (UInt32)port.integerValue,&readStream, &writeStream);
    
    
    _inputStream = (__bridge_transfer NSInputStream *)readStream;
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    
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

//打开网络流,连接服务器,需要在主线程中连接,
- (BOOL)openStream
{
    if (_inputStream != nil) {
        return YES;
    }
    
//    [NSStreamAdditions getStreamsToHostNamed:self.hostIP
//                                        port:self.port
//                                 inputStream:&inputStream
//                                outputStream:&outputStream];
    
    [_inputStream setDelegate:self];//设置代理，表示回调部分在delegate类里找
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                           forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                            forMode:NSDefaultRunLoopMode];
    
    [_inputStream open];
    [_outputStream open];
    
    //设置状态
    //第一次收到可以向缓存发送数据事件
    _isFirstFourBytes = YES;
    _delayTime = 5.0;
    _flag = RECV;

    //是否连接超时，连接后，设置个延时函数即可，可以发送数据后，取消延时的函数(对于那种连接后，没有回数据断开的，也可以在收到数据在取消延时)，如果系统又设置超时的函数更好。
    _ConnectOverTimer = YES;
    [self performSelector:@selector(checkConnectOverTime) withObject:nil afterDelay:_delayTime];
    
    return YES;
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
            jsonDictionary = data;
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
        dataLenthg = (int)[postData length];
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
                    //将四个字节大小端转换
                    _remainingToRead = ((bufferLen[3] << 24) & 0xff000000) + ((bufferLen[2] << 16) & 0xff0000) + ((bufferLen[1] << 8) & 0xff00) + (bufferLen[0] & 0xff);
                    _isFirstFourBytes = NO;
                }
                else
                {
                    NSLog(@"inputStream not 4 head");
                    [self close];
                    //Error Control
                }
            }else{
                uint8_t buffer[32768];
                if (self.recverData == nil) {
                    self.recverData = [[NSMutableData alloc] init];
                }
                
                int actuallyRead = (int)[_inputStream read:buffer maxLength:sizeof(buffer)];
                
                if(actuallyRead == -1){
                    [self close];
                    //Error Control
                }   else if(actuallyRead == 0)  {
                    //Do something if you want
                }   else    {
                    [self.recverData appendBytes:buffer length:actuallyRead];
                    _remainingToRead -= actuallyRead;
                    
                }
                    
                if(_remainingToRead == 0)
                {
                    [self.dataDelegate streamDataRecvSuccess:self.recverData];
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                        NSLog(@"raw data : %@", self.recverData);
                    });
                    _isFirstFourBytes = YES;
                    self.recverData = nil;
                }
            }
            
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            
            [self canclCheckConnectOverTimer];
            
            if (self.flag == SEND) {
                NSInteger left = [self.sendData length];
                int count = 0;
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
                    
                    if (left < MaxSend)
                    {
                        n = (int)[_outputStream write:[self.sendData bytes] maxLength:left];
                    }
                    else
                    {
                        n = (int)[_outputStream write:[self.sendData bytes] maxLength:MaxSend];
                    }
                    
                    if (n <= 0) //这地方会不会导致图片发送不完整
                    {
                        // break;
                    }
                    
                    count += n;
                    left -= n;
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
                    NSLog(@"send operation is complete！");
                });
                self.flag = RECV;
            }
            
            break;
            
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            [_errorDelegate streamEventErrorOccurredAction:[aStream streamError]  type:event];
            [self close];
            break;
            
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncountered";
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(checkConnectOverTime)
                                               object:nil];
}

-(void)close{
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
    //[self.errorDelegate streamEventClose];
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
            NSMutableArray *arry = data;
            for (NSDictionary *set in arry) {
                NSNumber *number = [set valueForKey:@"number"];
                NSNumber *pressure = [set valueForKey:@"pressure"];
                NSNumber *timeout = [set valueForKey:@"time"];
                NSString *numberKey = [NSString stringWithFormat:@"item%d",[number intValue]];
                [keysAndValues setObject:[NSDictionary dictionaryWithObjectsAndKeys:pressure,@"pressure",timeout,@"timeout", nil] forKey:numberKey];
            }
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:keysAndValues,@"auto",nil];
            break;
        }
        case XTSDataManuelMode: {
            keysAndValues = data;
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:keysAndValues,@"hand",nil];
            break;
        }
        case XTSDataStateRequireMode: {
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"ok",@"state", nil];
            break;
        }
        case XTSDataPhotoMode: {
            jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"photo",@"photo", nil];
            break;
        }
            
    }
    return jsonDictionary;
}

@end

