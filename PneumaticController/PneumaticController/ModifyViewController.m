//
//  ModifyViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "ModifyViewController.h"
//#import "AutoModeViewController.h"
#import "XTSSocketController.h"

//  要请求修改的类型，根据所需项目增减
//
enum XTSModifyType{
    XTSModifyFirst=1,
    XTSModifySecond,
    XTSModifyThird,
    XTSModifyFour,
    XTSModifyFive,
    XTSModifySix,
    XTSModifySeven,
}modifyType;

@class AutoModeViewController;

@interface ModifyViewController (){
    MBProgressHUD *HUD; //菊花
}
@property (nonatomic,strong) XTSSocketController *socker;
//修改按钮集合
@property (strong,nonatomic) IBOutletCollection(UIButton) NSArray *modifyButtons;
@property (strong,nonatomic) IBOutletCollection(UIButton) NSArray *myButtons;
//对应的文本标签
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    for (UIButton *button in self.myButtons) {
        button.layer.cornerRadius = button.frame.size.width/2;
        button.backgroundColor = [self getRadomColor];
        button.tintColor = [UIColor blackColor];
        if ([self.modifyButtons indexOfObject:button] != NSNotFound) {
            [button addTarget:self
                       action:@selector(buttonPress:)
             forControlEvents:UIControlEventTouchUpInside];
        }
    }   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - IBAction

-(void)buttonPress:(id)sender{
    //NSLog(@"%@",sender);
    //传入的按键的tag值＝＝修改项目类型
    UIButton *button = (UIButton *)sender;
    NSUInteger tag = button.tag;
    NSString *title;
    NSString *message = @"请输入要指定的值";
    
    switch (tag) {
        case XTSModifyFirst:
            title = @"升压";
            break;
        case XTSModifySecond:
            title = @"降压";
            break;
        default:
            
            break;
    }
    
    ModifyViewController * __weak weakself = self;
    //__block NSString *value;
    
    //对话框弹出
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSomeLog:) name:@"GOOD" object:nil];
    
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        for (UILabel *label in weakself.labels) {
            if (label.tag == tag) {
                label.text = alertController.textFields.firstObject.text;
                //按下ok后准备菊花显示，直到服务器通讯的结果返回
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.tabBarController.view addSubview:HUD];
                HUD.delegate = self;
                HUD.labelText = @"正在设置";
                HUD.dimBackground = YES;
                [HUD showWhileExecuting:@selector(sendData2Server:) onTarget:self withObject:label.text animated:YES];
            }
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidChangeNotification
                                                      object:nil];
    }];
    okAction.enabled = NO;
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //添加ok、cancel和输入文本框
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.delegate = self;
        textField.placeholder = title;
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - 输入框为空ok键不激活
- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    UITextField *textField = alertController.textFields.firstObject;
    if (alertController) {
        UIAlertAction *okAction = alertController.actions.firstObject;
        okAction.enabled = [textField text].length > 0;
    }
}

#pragma mark - 输入检查

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // allow backspace
    if (range.length > 0 && [string length] == 0) {
        return YES;
    }
    // do not allow . at the beggining
    if (range.location == 0 && [string isEqualToString:@"."]) {
        return NO;
    }
    // currentField指的是当前确定的那个输入框,当前面的字符有小数点的时候就不替换
    NSString *currentText = textField.text;
    if ([string isEqualToString:@"."] && [currentText rangeOfString:@"." options:NSBackwardsSearch].length == 1) {
        string = @"";
        //alreay has a decimal point
        return NO;
    }
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    //AutoModeViewController *autoModeController=(AutoModeViewController *)segue.destinationViewController;
    //autoModeController.modifyControllerx=self;
}


#pragma mark - Connect Function

-(void)sendData2Server:(NSString *)text{
    NSLog(@"%@\n",text);
    [NSThread sleepForTimeInterval:3];
    HUD.labelText = @"设置成功";
}

#pragma mark - 随机颜色

- (UIColor *)getRadomColor{
    //    + (UIColor *)blackColor;      // 0.0 white
    //    + (UIColor *)darkGrayColor;   // 0.333 white
    //    + (UIColor *)lightGrayColor;  // 0.667 white
    //    + (UIColor *)whiteColor;      // 1.0 white
    //    + (UIColor *)grayColor;       // 0.5 white
    //    + (UIColor *)redColor;        // 1.0, 0.0, 0.0 RGB
    //    + (UIColor *)greenColor;      // 0.0, 1.0, 0.0 RGB
    //    + (UIColor *)blueColor;       // 0.0, 0.0, 1.0 RGB
    //    + (UIColor *)cyanColor;       // 0.0, 1.0, 1.0 RGB
    //    + (UIColor *)yellowColor;     // 1.0, 1.0, 0.0 RGB
    //    + (UIColor *)magentaColor;    // 1.0, 0.0, 1.0 RGB
    //    + (UIColor *)orangeColor;     // 1.0, 0.5, 0.0 RGB
    //    + (UIColor *)purpleColor;     // 0.5, 0.0, 0.5 RGB
    //    + (UIColor *)brownColor;      // 0.6, 0.4, 0.2 RGB
    //    + (UIColor *)clearColor;      // 0.0 white, 0.0 alpha
    
    NSUInteger number;
    number = arc4random() % 6;
    //number = 5;
    UIColor *color;
    
    switch (number) {
        case 0:
            color = [UIColor colorWithRed:253.0/255.0 green:159.0/255.0 blue:37.0/255.0 alpha:1.0];
            break;
        case 1:
            color = [UIColor colorWithRed:253.0/255.0 green:95.0/255.0 blue:102.0/255.0 alpha:1.0];
            break;
        case 2:
            color = [UIColor colorWithRed:253.0/255.0 green:209.0/255.0 blue:50.0/255.0 alpha:1.0];
            break;
        case 3:
            color = [UIColor colorWithRed:253.0/255.0 green:95.0/255.0 blue:103.0/255.0 alpha:1.0];
            break;
        case 4:
            color = [UIColor colorWithRed:253.0/255.0 green:159.0/255.0 blue:37.0/255.0 alpha:1.0];
            break;
        case 10:
            color = [UIColor colorWithRed:84.0/255.0 green:199.0/255.0 blue:239.0/255.0 alpha:1.0];
            break;
        case 5:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
        case 6:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
        case 7:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
        case 8:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
        case 9:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
        default:
            color = [UIColor colorWithRed:138.0/255.0 green:139.0/255.0 blue:249.0/255.0 alpha:1.0];
            break;
    }
    
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    color = [ UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    
    return color;
}


@end
