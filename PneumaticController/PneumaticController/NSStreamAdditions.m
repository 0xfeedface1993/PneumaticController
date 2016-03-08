//
//  NSStreamAdditions.m
//  气压控制
//
//  Created by 0xfeedface on 16/3/8.
//  Copyright © 2016年 virus1993. All rights reserved.
//

#import "NSStreamAdditions.h"

@implementation NSStream (MyAdditions)



+ (void)getStreamsToHostNamed:(NSString*)hostName
                         port:(NSInteger)port
                  inputStream:(NSInputStream **)inputStreamPtr
                 outputStream:(NSOutputStream **)outputStreamPtr
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert(hostName != nil);
    assert( (port > 0) && (port <65536) );
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(
                                       NULL,
                                       (__bridge CFStringRef) hostName,
                                       (int)port,
                                       ((inputStreamPtr  != nil) ?&readStream : NULL),
                                       ((outputStreamPtr != nil) ? &writeStream : NULL)
                                       );
    if (inputStreamPtr != NULL) {
        *inputStreamPtr = [NSMakeCollectable(readStream) autorelease];
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = [NSMakeCollectable(writeStream) autorelease];
    }
}
@end
