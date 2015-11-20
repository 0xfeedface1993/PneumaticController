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
    //initialize new mutable data
    NSMutableData *data = [NSMutableData dataWithBytes:@"Hello World!" length:13];
    self.sendData = data;
    
    //initialize url that is going to be fetched.
    NSURL *url = [NSURL URLWithString:@"http://10.88.132.160:5000/current-pressure"];// http://10.88.132.160:5000/current-pressure" http://douban.fm/j/mine/playlist?type=n&h=&channel=0&from=mainsite&r=4941e23d79
    
    //initialize a request from url
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[url standardizedURL]];
    
    //set http method
    [request setHTTPMethod:@"GET"];
    //(2)超时时间
    [request setTimeoutInterval:5];
    
    //(3)缓存策略
    [request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"]; //告诉服务,返回的数据需要压缩
    //initialize a post data
    //NSString *postData = [[NSString alloc] initWithString:@"fname=example&lname=example"];
    //set request content type we MUST set this value.
    
   // [request setValue:@"application/x-www-form-urlencoded; charset=utf-8"
//   forHTTPHeaderField:@"Content-Type"];
    
    //set post data of request
   // [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //initialize a connection from request
   // NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //self.connection = connection;
    //start the connection
    //NSURLSession
    //[connection start];
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
     self.urlSession =  [NSURLSession sharedSession];
    
    self.sessionDataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
         //NSLog(@"recive data is %@\n",data);
        if (error == nil) {
            /*
             NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
             NSLog(@"data: %@", dataStr);
             */
            
            //json --> data
           NSError *error_json;
            NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error_json];
           //NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:nil error:nil];
            /*
             options:
             1.读取reading
             NSJSONReadingMutableContainers 生成可变的对象,不设置这个option,默认是创建不可变对象
             NSJSONReadingMutableLeaves 生成可变的字符串MutableString(iOS7+有bug)
             NSJSONReadingAllowFragments 允许json数据最外层不是字典或者数组
             2.写入writing
             NSJSONWritingPrettyPrinted 生成json数据是格式化的,有换行,可读性高
             */
            //data --> json
            //NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"data: %@", jsonData);
        }else{
            NSLog(@"erro : %@",error);
        }
    }];
    
    [self.sessionDataTask resume];
    
}

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

}

/*
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}*/
@end
