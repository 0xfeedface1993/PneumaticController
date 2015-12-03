//
//  XTSInfoCell.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface XTSInfoCell : UITableViewCell

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) id value;

@property (strong, nonatomic) NSManagedObject *hero;

@end
