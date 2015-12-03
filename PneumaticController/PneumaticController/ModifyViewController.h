//
//  ModifyViewController.h
//  PneumaticController

//  可根据不同的按键响应不同的修改项目，修改后会提示进度菊花

//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

//  要请求修改的类型，根据所需项目增减
//
enum XTSModifyType{
    XTSModifyFirst=1,
    XTSModifySecond,
    XTSModifyThird,
    XTSModifyFour,
    XTSModifyFive,
    XTSModifySix,
    XTSModifySeven,
}modifyType;

@interface ModifyViewController : UIViewController<MBProgressHUDDelegate>

//修改按钮集合
@property (strong,nonatomic) IBOutletCollection(UIButton) NSArray *modifyButtons;
//对应的文本标签
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;

@end
