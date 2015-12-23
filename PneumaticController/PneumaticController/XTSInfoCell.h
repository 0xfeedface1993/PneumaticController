//
//  XTSInfoCell.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define kLabelTextColor [UIColor colorWithRed:1.0f green:0.1f blue:0.2f alpha:0.8f]

@interface XTSInfoCell : UITableViewCell

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) id value;

@property (strong, nonatomic) NSManagedObject *hero;

@end
