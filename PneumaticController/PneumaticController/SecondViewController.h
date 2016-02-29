//
//  SecondViewController.h
//  PneumaticController
//
//  这是显示图片的视图控制器，可以实时从服务端请求得到图形数据并显示，
//  若启动为连接上服务器则显示最近更新图片
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSSocketController.h"

@interface SecondViewController : UIViewController <XTSSocketControllerStreamEventDataProcessDelegate,XTSSocketControllerStreamEventErrorOccurredDelegate>
@end

