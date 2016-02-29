//
//  SecondViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/13.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "SecondViewController.h"
#import "XTSHTTPController.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
#import <ImageIO/ImageIO.h>

@interface SecondViewController ()
@property (strong, nonatomic) XTSSocketController *socker;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
@property (weak, nonatomic) IBOutlet UILabel *photoTime;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *defaultImage;
@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.defaultImage = [UIImage imageNamed:@"default"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPhoto:)];
    [self.photoImage addGestureRecognizer:tap];
    [self.photoImage setUserInteractionEnabled:YES];
    [self.photoImage setImage:self.defaultImage];
    [self updatePhotoTime];

    UIButton *refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(250, 20, 60, 60)];
    refreshBtn.layer.cornerRadius = refreshBtn.frame.size.height/2;
    refreshBtn.backgroundColor = [UIColor redColor];
    refreshBtn.tintColor = [UIColor whiteColor];
    //refreshBtn.titleLabel.textColor = [UIColor whiteColor];
    [refreshBtn setTitle:[NSString stringWithFormat:@"无时间"] forState:UIControlStateNormal];
    [refreshBtn addTarget:self action:@selector(updatePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:refreshBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 更新时间
- (void)updatePhotoTime {
    if (self.photoImage.image != self.defaultImage && self.photoImage.image != nil) {
        //读取时间
        CGImageSourceRef cImageSource = CGImageSourceCreateWithData((__bridge CFDataRef)UIImagePNGRepresentation(self.photoImage.image), NULL);
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:NO], (NSString *)kCGImageSourceShouldCache,
                                 nil];
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(cImageSource, 0, (__bridge CFDictionaryRef)options);
        NSLog(@"%@",imageProperties);
        
        CFDictionaryRef tiff = CFDictionaryGetValue(imageProperties, kCGImagePropertyTIFFDictionary);
        if (tiff) {
            NSString *dateTime = (NSString *)CFDictionaryGetValue(tiff, kCGImagePropertyTIFFDateTime);
            if (dateTime) {
                self.photoTime.text = dateTime;
            }   else    {
                self.photoTime.text = [NSString stringWithFormat:@"无时间"];
            }
        }   else {
            self.photoTime.text = [NSString stringWithFormat:@"无时间"];
        }
    }   else    {
        [self.photoTime setText:[NSString stringWithFormat:@"无时间"]];
    }
}

#pragma mark - 点击按钮下载图片

- (void)updatePhoto {
    self.photoImage.image = self.defaultImage;
    
    if (self.socker == nil) {
        self.socker = [[XTSSocketController alloc] init];
        self.socker.flag = 1;
        self.socker.errorDelegate = self;
        self.socker.dataDelegate = self;
        NSString *ip = [[NSUserDefaults standardUserDefaults] valueForKey: @"ip"];
        [self.socker initNetworkCommunication: nil hostIP: ip];
    }
    
    NSDictionary *dataPack = [self.socker packSendData: nil WithMode: XTSDataPhotoMode];
    if (![self.socker sendDataWithMode: XTSDataPhotoMode dataPack: dataPack]) {
        NSLog(@"upload failed!");
    }
    
}

#pragma mark - 点击图片
- (void)showPhoto:(UITapGestureRecognizer *)tap{
    UIImageView *imageView = (UIImageView *)tap.view;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = imageView.image;
    imageInfo.referenceRect = imageView.frame;
    imageInfo.referenceView = imageView.superview;
    imageInfo.referenceContentMode = imageView.contentMode;
    imageInfo.referenceCornerRadius = 1;
    
    JTSImageViewController *imageViewContainer = [[JTSImageViewController alloc] initWithImageInfo:imageInfo mode:JTSImageViewControllerMode_Image backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    [imageViewContainer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
}




#pragma mark - StreamEventErrorOccurred Delegate

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type{
    if ([type isEqualToString:@"NetEventConnectOverTime"]) {
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"连接服务器超时" message:@"请检查你的网络和服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
}

-(void)streamEventOpenSucces{
    NSLog(@"Stream Open Succes！");
}

-(void)streamEventClose{
    NSLog(@"Stream Close！");
    //[self.refreshControl endRefreshing];
}

#pragma mark - StreamEventDataProcess Delegate

-(void)streamDataRecvSuccess:(NSData *)data{
    //base64转图片png
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        NSData *decdeData = [[NSData alloc] initWithBase64EncodedData:data options:NSDataBase64DecodingIgnoreUnknownCharacters];
        dispatch_async(dispatch_get_main_queue(), ^() {
            self.photoImage.image = [UIImage imageWithData:decdeData];
            [self updatePhotoTime];
        });
    });
    //断开socker
    self.socker.errorDelegate = nil;
    self.socker.dataDelegate = nil;
    self.socker = nil;
}

@end
