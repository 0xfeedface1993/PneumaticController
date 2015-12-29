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
//  要请求修改的类型，根据所需项目增减，用于识别标签文本
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
//socket，私有持有，当出错或者没有响应或数据上传结束后关闭流，下次使用再打开
@property (nonatomic,strong) XTSSocketController *socker;
@end

@implementation ModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //“启动”按键按下后由buttonpress响应
    for (UIButton *button in self.modifyButtons) {
        [button addTarget:self
                   action:@selector(buttonPress:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
    //NSLog(@"w:%f,h:%f",self.view.bounds.size.width,self.view.bounds.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

#pragma mark - IBAction

/*
 模式界面“启动”按键按下后，首先确定是启动哪种模式启动，这里响应的是两种：单点升压模式和单点降压模式，至于自动模式由stroyboard的show来响应。升压模式和降压模式功能十分相近，不同之处就是标题，代码流程如下：

 1.取按钮的tag值，tag值在stroyboard指定为：
    （1）升压tag＝5
    （2）降压tag＝6
   确定弹出的警告框显示文字
 
 2.显示警告视图，警告视图添加：
    （1）一个文本输入框，文本输入框输入键盘限制为数字输入。
    （2）确定键，在回调函数块中显示等待画面，并调用上传方法 sendData2Server: 上传数据，
        等待画面结束由错误和流结束来决定
    （3）取消键，无任何操作
 
 */

-(void)buttonPress:(id)sender{
    //NSLog(@"%@",sender);
    //传入的按键的tag值＝＝修改项目类型
    UIButton *button=(UIButton *)sender;
    NSUInteger tag=button.tag;
    NSString *title;
    NSString *message=@"请输入要指定的值";
    
    switch (tag) {
        case XTSModifyFive:
            title=@"升压";
            break;
        case XTSModifySix:
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
    
    //weak 关键字表明函数块不能持有self，否则会造成死锁，内存无法释放
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

/*
 
 通过socket发送数据到服务器，参数为用户输入的数字文本。
 首先
 1.取得服务器的ip，这里使用NSUserDefaults存储ip
 2.准备数据，对于非自动模式只需要准备如下的字典：
    ｛
        "pressure"：105.5
        "timeout"：5
     ｝
   压力值为浮点型，保压时间都是5分钟
 3.实例化socket，建立连接，发送数据。
 此时数据并没有完全符合标准，还需要转化，更多工作在socket类里面有详细说明
 
 */

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
