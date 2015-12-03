//
//  ModifyViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/25.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "ModifyViewController.h"


@interface ModifyViewController (){
    MBProgressHUD *HUD; //菊花
}

@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    for (UIButton *button in self.modifyButtons) {
        [button addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
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
    UIButton *button=(UIButton *)sender;
    NSUInteger tag=button.tag;
    NSString *title;
    NSString *message=@"请输入要指定的值";
    
    switch (tag) {
        case XTSModifyFirst:
            title=@"平原表（800）检定";
            break;
        case XTSModifySecond:
            title=@"高原表（500）检定";
            break;
        case XTSModifyThird:
            title=@"气压计检定";
            break;
        case XTSModifyFour:
            title=@"输入表格数据";
            break;
        case XTSModifyFive:
            title=@"单点升检定";
            break;
        case XTSModifySix:
            title=@"单点降检定";
            break;
        case XTSModifySeven:
            title=@"振筒自动检定";
            break;
        default:
            
            break;
    }
    ModifyViewController * __weak weakself=self;
    //__block NSString *value;
    
    //对话框弹出
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSomeLog:) name:@"GOOD" object:nil];
    
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        for (UILabel *label in weakself.labels) {
            if (label.tag==tag) {
                label.text=alertController.textFields.firstObject.text;
                //[self  makeSomeLog];
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"GOOD" object:alertController.textFields.firstObject.text];
                //按下ok后准备菊花显示，直到服务器通讯的结果返回
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.delegate = self;
                HUD.labelText = @"正在设置";
                HUD.dimBackground = YES;
                [HUD showWhileExecuting:@selector(sendData2Server:) onTarget:self withObject:label.text animated:YES];
                
            }
        }
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //添加ok、cancel和输入文本框
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder=title;
        textField.keyboardType=UIKeyboardTypeDecimalPad;
        //textField.ke
        //value=[textField.text mutableCopy];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Connect Function

-(void)sendData2Server:(NSString *)text{
    NSLog(@"%@\n",text);
    //hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //hud.mode=MBProgressHUDAnimationZoom;//枚举类型不同的效果
    //hud.labelText=@"修改中";
    [NSThread sleepForTimeInterval:3];
    //[MBProgressHUD hideHUDForView:self.view animated:YES];
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GOOD" object:nil];
}

@end
