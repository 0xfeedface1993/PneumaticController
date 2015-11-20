//
//  FirstViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.sendPressureValue.text=[NSString stringWithFormat:@"%5f",self.sendPresuressValueSlider.value];
    self.pressureValueNow.text=@"未收到气压值";
    UIButton *button;
    button=(UIButton *)[self.view viewWithTag:11];
    [button.layer setMasksToBounds:YES];
    [button.layer setCornerRadius:10.0];//设置矩形四个圆角半径
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchSocketPort:(id)sender {
    /*
    if ([_SocketControl isOn]==YES) {
        
        XTSSocketController *soketer=[[XTSSocketController alloc] init];
        soketer.flag=1;
        char *str="hello world!";
        NSData *sendeData=[NSData dataWithBytes:str length:strlen(str)+1];
        _dataPack=sendeData;
        soketer.sendData=_dataPack;
        soketer.errorDelegate=self;
        self.socketer=soketer;
        [soketer initNetworkCommunication:_dataPack hostIP:HOST_IP];
        
    }else{
        if(self.socketer!=nil){
            [self.socketer close];
            self.socketer=nil;
        }
    }*/
    switch ([_SocketControl isOn]) {
        case YES:
            self.httper=[[XTSHTTPController alloc] init];
            [_httper initWithHTTP];
            break;
        case NO:
            self.httper=nil;
            break;
        default:
            break;
    }
}

-(void)streamEventErrorOccurredAction:(NSError *)error{
    
}

- (IBAction)updatePressureValue:(id)sender {
    float sliderValue;
    sliderValue=self.sendPresuressValueSlider.value;
    self.sendPressureValue.text=[NSString stringWithFormat:@"%5f",sliderValue];
}
@end
