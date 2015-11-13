//
//  SecondViewController.h
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UILabel *photoTime;
@property (weak, nonatomic) IBOutlet UIButton *updatePhoto;

- (IBAction)updatePhotoDate:(id)sender;

@end

