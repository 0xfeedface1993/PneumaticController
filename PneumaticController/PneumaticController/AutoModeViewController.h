//
//  AutoModeViewController.h
//  PneumaticController
//
//  Created by virus1993 on 15/12/3.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "managedObjectViewController.h"
#import "XTSSocketController.h"

//@class ModifyViewController;

@interface AutoModeViewController : managedObjectViewController<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,XTSSocketControllerStreamEventErrorOccurredDelegate,XTSSocketControllerStreamEventDataProcessDelegate>
//@property (nonatomic,weak) ModifyViewController *modifyControllerx;
@end
