//
//  SecondViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "SecondViewController.h"
#import "XTSHTTPController.h"
@interface SecondViewController ()
@property (strong, nonatomic) XTSHTTPController *httper;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //self.photoImage.image=self.defaultImage;
    self.defaultImage=[UIImage imageNamed:@"IMG_0035.jpg"];
    [self.photoImage setImage:self.defaultImage];
   
    self.photoTime.text=[NSString stringWithFormat:@"%@",[NSDate date]];
     //self.photoTime.adjustsFontSizeToFitWidth=YES;
    //self.photoTime.font=[UIFont systemFontOfSize:16];
    //NSDateComponents *dateComponent=[NSDateComponents ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction

- (IBAction)updatePhotoDate:(id)sender {
    //self.httper=[[XTSHTTPController alloc] init];
    //[_httper initWithJPG];
    
    
    //[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.httper.imageURL]]];//@"http://10.88.132.160:5000/static/0.jpg"IMG_0035.jpg
}
@end
