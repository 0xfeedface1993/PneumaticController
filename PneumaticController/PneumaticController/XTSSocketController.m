//
//  XTSSocketController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSSocketController.h"

@interface XTSSocketController()

@end



@implementation XTSSocketController

-(void)initNetworkCommunication:(NSData *)data  hostIP:(NSString * )hostIP{
    self.Host_IP=hostIP;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;

    CFStreamCreatePairWithSocket(NULL, (__bridge CFStringRef)self.Host_IP, &readStream, &writeStream);
    
    
    _inputStream = (__bridge_transfer NSStream *)readStream;
    _outputStream = (__bridge_transfer NSStream *)writeStream;
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
    
}

-(void)setSendData:(XTSDataPack *)sendData{
    if (sendData!=nil) {
        _sendData=sendData;
    }
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
     NSString *event;
    switch (eventCode) {
            
        case NSStreamEventNone:
            event=@"NSStreamEventNone";
            break;
            
        case NSStreamEventOpenCompleted:
            event=@"NSStreamEventOpenCompleted";
            break;
            
        case NSStreamEventHasBytesAvailable:
            event=@"NSStreamEventHasBytesAvailable";
            if (_flag==RECV&&aStream==_inputStream) {
                NSMutableData *input=[[NSMutableData alloc] init];
                uint8_t buffer[1024];
                int len=1024;
                while ([_inputStream hasBytesAvailable]) {
                    len=[_inputStream read:buffer maxLength:len];
                    if (len>0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                self.recverData=input;
                
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            event=@"NSStreamEventHasSpaceAvailable";
            if (_flag==SEND&&aStream==_outputStream&&_sendData!=nil) {
                NSUInteger bytesLength=[self.sendData length];
                uint8_t *buffer=malloc(bytesLength);
                [_outputStream write:[self.sendData bytes] maxLength:bytesLength];
                [_outputStream close];
                free(buffer);
            }
            break;
            
        case NSStreamEventErrorOccurred:
            event=@"NSStreamEventErrorOccurred";
            [_errorDelegate streamEventErrorOccurredAction:[aStream streamError]];
            [self close];
            break;
            
        case NSStreamEventEndEncountered:
            event=@"NSStreamEventEndEncountered";
            [_errorDelegate streamEventErrorOccurredAction:[aStream streamError]];
            [self close];
            break;
            
        default:
            break;
    }
}

-(void)close{
    [_outputStream close];
    [_outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream setDelegate:nil];
    
    [_inputStream close];
    [_inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream setDelegate:nil];
}

-(void)open{
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_inputStream open];
    [_outputStream open];
}
@end
