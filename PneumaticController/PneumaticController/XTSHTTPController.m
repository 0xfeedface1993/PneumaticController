//
//  XTSHTTPController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/20.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "XTSHTTPController.h"

@implementation XTSHTTPController

-(void)initWithHTTP{

    
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"http://10.88.132.160:5000/current-pressure"];// http://10.88.132.160:5000/current-pressure" http://douban.fm/j/mine/playlist?type=n&h=&channel=0&from=mainsite&r=4941e23d79
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    //set http method;
    [request setHTTPMethod:@"GET"];
    //(2)超时时间
    [request setTimeoutInterval:5];
    
    //(3)缓存策略
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    self.urlSession =  [NSURLSession sharedSession];
    
    self.sessionDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
         //NSLog(@"recive data is %@\n",data);
        if (error == nil) {
            
             NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"data: %@", dataStr);
            
            NSError *error_check_json;
            NSDictionary *revData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
            NSLog(@"%@",revData);
          
        }else{
            NSLog(@"erro : %@",error);
        }
    }];
    
    [self.sessionDataTask resume];
    
}
-(void)initWithJPG{
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"http://10.88.132.160:5000/image"];// http://10.88.132.160:5000/current-pressure" http://douban.fm/j/mine/playlist?type=n&h=&channel=0&from=mainsite&r=4941e23d79
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    //set http method;
    [request setHTTPMethod:@"GET"];
    //(2)超时时间
    [request setTimeoutInterval:5];
    
    //(3)缓存策略
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [request setValue:@"image/jpeg"
   forHTTPHeaderField:@"Content-Type"];
    
    self.urlSession =  [NSURLSession sharedSession];
    
   // __block NSMutableString *URLImage;
    //__block NSString *dataStr;
    self.sessionDataTask = [self.urlSession dataTaskWithRequest:request];
    
    [self.sessionDataTask resume];
}

-(void)initWithPOST{
        
        //initialize url that is going to be fetched.
        NSURL *url = [NSURL URLWithString:@"http://10.88.132.160:5000/data"];// http://10.88.132.160:5000/current-pressure" http://douban.fm/j/mine/playlist?type=n&h=&channel=0&from=mainsite&r=4941e23d79
        
        //initialize a request from url
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
        
        //set http method
        [request setHTTPMethod:@"POST"];
        //(2)超时时间
        [request setTimeoutInterval:5];
        
        //(3)缓存策略
        [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];

        NSDictionary *jsonDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"photo_data",@"photo_data", @"photo_filename",@"0.png",@"time",[[NSString alloc] initWithFormat:@"%@",[NSDate date]],nil];
        
        NSError *error_json;
        NSData *postData;
        if ([NSJSONSerialization isValidJSONObject:jsonDictionary]) {
            postData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&error_json];
            //NSLog(@"%@",postData);
        }else{
            postData = [[NSData alloc] init];
            NSLog(@"nonono");
        }
        
        //set request content type we MUST set this value.
        /*NSDictionary *checkData=[NSJSONSerialization JSONObjectWithData:postData options:NSJSONWritingPrettyPrinted error:&error_json];
        NSLog(@"%@",checkData);*/
        
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8"
       forHTTPHeaderField:@"Content-Type"];
        
        //set post data of request
        
        [request setHTTPBody:postData];
    //NSURLSessionConfiguration *sessionConfig=[];
       // self.urlSession =  [NSURLSession sessionWithConfiguration:<#(nonnull NSURLSessionConfiguration *)#> delegate:<#(nullable id<NSURLSessionDelegate>)#> delegateQueue:<#(nullable NSOperationQueue *)#>];
        
        self.sessionDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            //NSLog(@"recive data is %@\n",data);
            if (error == nil) {
                
                NSError *error_check_json;
                NSDictionary *revData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
                NSLog(@"%@",revData);
                
            }else{
                NSLog(@"erro : %@",error);
            }
        }];
        
        [self.sessionDataTask resume];
}
/*
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSLog(@"%@\n",data);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler\n");

}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    NSLog(@"-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask\n");

}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
    NSLog(@"-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask\n");

}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler{
    NSLog(@"-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask willCacheResponse:(NSCachedURLResponse *)proposedResponse completionHandler:(void (^)(NSCachedURLResponse * _Nullable))completionHandler\n");

}*/

/*
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}*/
@end
