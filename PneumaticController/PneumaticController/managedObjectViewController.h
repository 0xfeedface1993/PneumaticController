//
//  managedObjectViewController.h
//  
//
//  Created by virus1993 on 15/12/3.
//
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
//#import "MBProgressHUD.h"

@class managedObjectConfiguration;

@interface managedObjectViewController : UITableViewController

@property (strong, nonatomic) managedObjectConfiguration *config;
@property (strong, nonatomic) NSManagedObject *managedObject;

-(void)save;
-(void)cancel;
@end
