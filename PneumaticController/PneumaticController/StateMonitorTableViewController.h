//
//  StateMonitorTableViewController.h
//  PneumaticController
//  显示当前状态
//  Created by virus1993 on 15/11/24.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"
#import "managedObjectViewController.h"
#import "XTSSocketController.h"

#define kIPAdressKey @"ip"



@class managedObjectConfiguration;

@interface StateMonitorTableViewController : managedObjectViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,XTSSocketControllerStreamEventErrorOccurredDelegate,XTSSocketControllerStreamEventDataProcessDelegate>

@end
