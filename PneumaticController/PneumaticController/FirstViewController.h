//
//  FirstViewController.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTSSocketController.h"
#import "XTSDataPack.h"
#import "XTSHTTPController.h"

static NSString *HOST_IP=@"10.88.132.16";

@interface FirstViewController : UIViewController<XTSSocketControllerStreamEventErrorOccurredDelegate>

@property (strong, nonatomic) NSString *test;
@property (weak, nonatomic) IBOutlet UILabel *pressureValueNow;
@property (weak, nonatomic) IBOutlet UILabel *sendPressureValue;
@property (weak, nonatomic) IBOutlet UISlider *sendPresuressValueSlider;
@property (weak, nonatomic) IBOutlet UISwitch *SocketControl;
@property (strong, nonatomic) XTSSocketController *socketer;
@property (strong, nonatomic) XTSHTTPController *httper;
@property (strong, nonatomic) NSData *dataPack;

- (IBAction)switchSocketPort:(id)sender;
- (IBAction)updatePressureValue:(id)sender;
@end

