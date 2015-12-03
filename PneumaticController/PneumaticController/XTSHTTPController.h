//
//  XTSHTTPController.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/20.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface XTSHTTPController : NSObject<NSURLSessionDataDelegate>
@property (nonatomic, assign) int flag;
//@property (weak, nonatomic) id<XTSSocketControllerStreamEventErrorOccurredDelegate> errorDelegate;
@property (strong, nonatomic) NSString *  Host_IP;
@property (strong, nonatomic) NSMutableData *recverData;
@property (strong, nonatomic) NSData *sendData;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSURLSession *urlSession;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (strong, nonatomic) NSString *imageURL;
//@property (nonatomic, copy) void (^myBlock)(NSData *data, NSURLResponse *response, NSError *error);

-(void)initWithHTTP;
-(void)initWithPOST;
-(void)initWithJPG;
@end
