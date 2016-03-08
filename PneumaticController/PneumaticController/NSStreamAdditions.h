//
//  NSStreamAdditions.h
//  气压控制
//
//  Created by 0xfeedface on 16/3/8.
//  Copyright © 2016年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (NSStreamAdditions)

+ (void)getStreamsToHostNamed:(NSString*)hostName

                         port:(NSInteger)port

                  inputStream:(NSInputStream **)inputStreamPtr

                 outputStream:(NSOutputStream **)outputStreamPtr;

@end