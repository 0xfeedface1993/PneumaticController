//
//  XTSTextCell.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSInfoCell.h"

#define RED_BUTTON @"红色按钮.jpg"
#define BLACK_BUTTON @"黑色按钮.png"

@interface XTSStateCell : XTSInfoCell
@property (strong, nonatomic) UIImageView *stateImageView;
@property (strong, nonatomic) UIImage *stateImage;
@end
