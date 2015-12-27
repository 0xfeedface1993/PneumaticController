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

#define kIPAdressKey @"ip"
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
    
    NSLog(@"w:%f,h:%f",self.view.bounds.size.width,self.view.bounds.size.height);
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
            title=@"升压";
            break;
        case XTSModifySecond:
            title=@"降压";
            break;
            /*
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
             */
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
                //NSDictionary *inputDictionary=[NSDictionary dictionaryWithObjectsAndKeys:, nil];
                //[HUD showWhileExecuting:@selector(sendData2Server:) onTarget:self withObject:label.text animated:YES];
                [HUD show:YES];
                [self sendData2Server:label.text];
                
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
    //[NSThread sleepForTimeInterval:3];
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *ip=[userDefaults valueForKey:kIPAdressKey];
    NSNumber *pressure=[[NSNumber alloc] initWithFloat:[text floatValue]];
    NSNumber *timeout=[[NSNumber alloc] initWithChar:5];
    NSDictionary *keysAndValues;
    
    XTSSocketController *soketer=[[XTSSocketController alloc] init];
    XTSDataMode mode=XTSDataManuelMode;
    keysAndValues=[NSDictionary dictionaryWithObjectsAndKeys:pressure,@"pressure",timeout,@"timeout", nil];
    soketer.errorDelegate=self;
    soketer.dataDelegate=self;
    self.socker=soketer;
    [self.socker initNetworkCommunication:keysAndValues hostIP:ip];
    //soketer.flag=1;
    if (![self.socker sendDataWithMode:mode dataPack:keysAndValues]) {
        NSLog(@"send data failed!");
    }else{
        //[self.tableView reloadData];
        //self.labels
         //[HUD hide:YES];
    }

}


#pragma mark - StreamEventErrorOccurred Delegate

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type{
    //NSLog(@"ErrorOccurred :%@ ,type: %@",[error localizedDescription],type);
    if ([type isEqualToString:@"NetEventConnectOverTime"]) {
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"连接服务器超时" message:@"请检查你的网络和服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //[self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
        [HUD hide:YES];
    }
    //[self.refreshControl endRefreshing];
}

-(void)streamEventOpenSucces{
    NSLog(@"Stream Open Succes！");
}

-(void)streamEventClose{
    NSLog(@"Stream Close！");
    //[self.refreshControl endRefreshing];
    [HUD hide:YES];
}

#pragma mark - StreamEventDataProcess Delegate

-(void)streamDataRecvSuccess:(NSData *)data{
    NSError *error_check_json;
    NSDictionary *revData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
    NSDictionary *state=[revData objectForKey:@"state"];
    //NSManagedObject *object=[[self.fetchedResultController fetchedObjects] lastObject];
    
}

@end
