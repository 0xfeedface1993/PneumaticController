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

@class managedObjectConfiguration;

@interface StateMonitorTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) managedObjectConfiguration *config;
@property (strong, nonatomic) NSManagedObject *managedObject;

-(void)save;
-(void)cancel;

@end
