//
//  FirstViewController.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UIViewController

@property (strong, nonatomic) NSString *test;
@property (weak, nonatomic) IBOutlet UILabel *pressureValueNow;
@property (weak, nonatomic) IBOutlet UILabel *sendPressureValue;
@property (weak, nonatomic) IBOutlet UISlider *sendPresuressValueSlider;
@property (weak, nonatomic) IBOutlet UISwitch *SocketControl;

@end
