//
//  StateMonitorTableViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/24.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "StateMonitorTableViewController.h"
#import "managedObjectConfiguration.h"
#import "XTSStateCell.h"
#import "SetHostIPViewController.h"
#import "AppDelegate.h"


#define XTSStateChangerate @"changerate"
#define XTSStateElectromagnet @"electromagnet"          //电磁铁
#define XTSStateHighPressureValve @"highpressurevalve"  //高压阀
#define XTSStateLowPressureValve @"lowpressurevalve"    //低压阀
#define XTSStatePressure @"pressure"                    //气压
#define XTSStateruntime @"runtime"                      //
#define XTSStateStableValve @"stablevalve"              //稳压阀
#define XTSStateTemperature @"temperature"              //温度
#define XTSStateVacuumpump @"vacuumpump"                //真空泵
#define XTSStateStableValveTimeout @"stablevalvetimeout"//保压时间到
#define XTSStateUSB @"usb"                              //串口状态

#define XTSStateCurrentChangeRate @"current_change_rate"           //保压时间
#define XTSStateCurrentTargetPress @"current_target_press"         //保压值
#define XTSStateRemainTime @"remain_time"         //保压时间

#define QSYStateChangerate @"changerate"
#define QSYStateElectromagnet @"electromagnet"          //电磁铁
#define QSYStateHighPressureValve @"high_press"         //高压阀
#define QSYStateLowPressureValve @"low_press"          //低压阀
#define QSYStatePressure @"pressure"                    //气压
#define QSYStateruntime @"runtime"                      //
#define QSYStateStableValve @"press_remain"             //稳压阀
#define QSYStateTemperature @"tempreture"              //温度
#define QSYStateVacuumpump @"pump"                      //真空泵
#define QSYStateStableValveTimeout @"timeout"           //保压时间到
#define QSYStateUSB @"serial"                           //串口状态

#define QSYStateCurrentChangeRate @"current_change_rate"           //保压时间
#define QSYStateCurrentTargetPress @"current_target_press"         //保压值
#define QSYStateRemainTime @"remain_time"         //保压时间


#define IdentifierONorOFF(x) ([x isEqualToString:@"启动"] ? @"红色按钮.jpg" : @"黑色按钮.png")

typedef NS_ENUM(NSInteger, TexTFieldType) {
    TexTFieldIP,
    TexTFieldPort
};

@interface StateMonitorTableViewController (){
    MBProgressHUD *HUD; //菊花
}
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultController;
@property (nonatomic, strong) XTSSocketController *socketer;
@property (nonatomic, strong) NSDictionary *nameZonePair;
@property (nonatomic, strong) NSTimer *connectionTimer;
@property (nonatomic, assign) BOOL isPopAlert;
@end

@implementation StateMonitorTableViewController
@synthesize fetchedResultController = _fetchedResultController;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isPopAlert = YES;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.config = [[managedObjectConfiguration alloc] initWithResource:@"StateMonitorList"];
    self.navigationItem.title = @"启动中";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshState)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                  target:self
                                                                  action:@selector(changeServer)];
    [self setSocketJOSNKeyAndCoreDataKeyPair];
    //    NSError *error;
    //    [self.fetchedResultController performFetch:&error];
    if ([[self.fetchedResultController fetchedObjects] count] == 0) {
        NSManagedObjectContext *managedObjectContext = [self.fetchedResultController managedObjectContext];
        NSEntityDescription *entity = [[self.fetchedResultController fetchRequest] entity];
        NSManagedObject *newReciveSet = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:managedObjectContext];
        NSError *error;
        
        if (![newReciveSet.managedObjectContext save:&error]) {
            
        }
    }
    //[self addTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.connectionTimer invalidate];
    //self.connectionTimer = nil;
    [self closeSocket];
    
}

- (void)addTimer {
    //实例化timer
    self.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                            target:self
                                                          selector:@selector(refreshState)
                                                          userInfo:nil
                                                           repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.connectionTimer
                                 forMode:NSRunLoopCommonModes];
    [self.connectionTimer fire];
}


/*
 数据库键名最好是固定的，所以需要建立与josn键名的关系，即使josn键名改变也可进行较小的修改
 另外，解析的时候更方便进行键值存储
 */

-(void)setSocketJOSNKeyAndCoreDataKeyPair{
    NSArray *XTSNames = [NSArray arrayWithObjects:XTSStateChangerate,
                                                XTSStateElectromagnet,
                                                XTSStateHighPressureValve,
                                                XTSStateLowPressureValve,
                                                XTSStatePressure,
                                                //XTSStateruntime,
                                                XTSStateStableValve,
                                                XTSStateStableValveTimeout,
                                                XTSStateTemperature,
                                                XTSStateUSB,
                                                XTSStateCurrentChangeRate,
                                                XTSStateCurrentTargetPress,
                                                XTSStateRemainTime,
                                                XTSStateVacuumpump, nil];
    NSArray *QSYNames = [NSArray arrayWithObjects:QSYStateChangerate,
                                                QSYStateElectromagnet,
                                                QSYStateHighPressureValve,
                                                QSYStateLowPressureValve,
                                                QSYStatePressure,
                                                //QSYStateruntime,
                                                QSYStateStableValve,
                                                QSYStateStableValveTimeout,
                                                QSYStateTemperature,
                                                QSYStateUSB,
                                                QSYStateCurrentChangeRate,
                                                QSYStateCurrentTargetPress,
                                                QSYStateRemainTime,
                                                QSYStateVacuumpump, nil];
    NSDictionary *nameZonePair = [NSDictionary dictionaryWithObjects:XTSNames forKeys:QSYNames];
    self.nameZonePair = nameZonePair;
}

/*
 fetchedResultController的getter方法，从数据库中读取我们需要的实体需要以下几个步骤（这里要取的是状态数据，也就是Recive实体）：
 1.获得数据库托管上下文 （NSManagedObjectContext），并设置获取请求（NSFetchRequest），不过要为它提供一个 NSEntityDescription，指定希望检索名为“Recive”的多个对象实体。还需要 NSSortDescriptor 提供检索结果的排序，这里我们用压力变化速率来排序，我们当前并不需要排序，只是使用过程需要这个参数
 2.调用initWithFetchRequest:managedObjectContext:sectionNameKeyPath:cacheName:方法进行检索
 
 */

-(NSFetchedResultsController *)fetchedResultController {
    if (_fetchedResultController != nil) {
        return _fetchedResultController;
    }
    NSFetchRequest *fetchReqest = [[NSFetchRequest alloc] init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Recive"
                                            inManagedObjectContext:managedObjectContext];
    
    [fetchReqest setEntity:entity];
    [fetchReqest setFetchBatchSize:20];
    
    NSString *sectionKey = @"changerate";
    
    NSSortDescriptor *sortDescriptor1 = [[NSSortDescriptor alloc] initWithKey:@"current_change_rate"
                                                                  ascending:YES];
    NSArray *sortDescriptiors = [[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchReqest setSortDescriptors:sortDescriptiors];
    
    _fetchedResultController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchReqest
                                                                 managedObjectContext:managedObjectContext
                                                                   sectionNameKeyPath:sectionKey
                                                                            cacheName:@"Recive"];
    
    NSError *error = NULL;
    if (![_fetchedResultController performFetch:&error]) {
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }
    
    return _fetchedResultController;
}

/*
 更新状态显示。需要使用socket传输数据，但是服务器ip必须不为空，更新步骤如下：
 1.检查是否ip为空，空着提示出错后面的代码不执行
 2.实例化socket，设置上传数据模式为请求数据模式，不需要我们准备数据，因为任何时候请求数据没有任何区别。
 3.发送数据
 4.等待数据回传
 5.解析回传数据，存入数据库，更新显示
 这个方法完成的是发送请求数据，回传数据的解析由代理协议XTSSocketControllerStreamEventDataProcessDelegate完成，也就是步骤4、5
 */

-(void)refreshState {
    self.title = @"正在连接...";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *ip = [userDefaults valueForKey:kIPAdressKey];
    NSString *port = [userDefaults valueForKey:kIPPortKey];

    if (ip.length == 0) {
        if (self.isPopAlert == YES) {
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"刷新失败" message:@"请先设置你的服务器ip" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                
            }];
            [alertView addAction:okAction];
            [[AppDelegate getCurrentVC] presentViewController:alertView animated:YES completion: ^() {
                self.title = @"未设置服务器ip";
            }];
        }
        return;
    }

    if (self.socketer == nil) {
       self.socketer = [[XTSSocketController alloc] init];
    }
    self.socketer.flag = 1;

    NSDictionary *keysAndValues;
    XTSDataMode mode = XTSDataStateRequireMode;
    _socketer.errorDelegate = self;
    _socketer.dataDelegate = self;

    [_socketer initNetworkCommunication:keysAndValues hostIP:ip port:port];
    if (![_socketer sendDataWithMode:mode dataPack:keysAndValues]) {
        NSLog(@"set send data failed!");
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"连接失败" message:@"请检查你的网络或者服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }else{
       
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 变更ip方法。通过警告视图中的文本框获得用户指定的ip值，存入NSUserDefaults
 */

-(void)changeServer {
    
    NSString *title = @"请设置你的服务器ip";
    NSString *message;
    //对话框弹出
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self configIP:alertController.textFields.firstObject.text
                  port:alertController.textFields.lastObject.text];
        //self.title = @"正在连接...";
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidChangeNotification
                                                      object:nil];
    }];
    [alertController addAction:okAction];
    okAction.enabled = NO;
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler: ^(UIAlertAction *action) {
        self.isPopAlert = YES;
    }];
    [alertController addAction:cancelAction];

    //添加ok、cancel和输入文本框
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *titleIP = [userDefaults valueForKey:kIPAdressKey];
        textField.text = titleIP;
        textField.placeholder = @"请输入服务器的ip";
        textField.keyboardType = UIKeyboardTypeDecimalPad;
        textField.delegate = self;
        textField.tag = TexTFieldIP;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification object:nil];
    }];
    
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *port = [userDefaults valueForKey:kIPPortKey];
        textField.text = port;
        textField.placeholder = @"请输入服务器的端口";
        textField.tag = TexTFieldPort;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertTextFieldDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }];
    self.isPopAlert = NO;
    [self presentViewController:alertController animated:YES completion: nil];
    
}

-(void)configIP:(NSString *)text port:(NSString *)port {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:text forKey:kIPAdressKey];
    [userDefaults setObject:port forKey:kIPPortKey];
}

#pragma mark - 输入检查

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == TexTFieldIP) {
        NSCharacterSet *nonNumberSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."]invertedSet];
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
        if (([string isEqualToString:@"."] && [currentText rangeOfString:@"." options:NSBackwardsSearch|NSAnchoredSearch].length == 1)) {
            string = @"";
            //alreay has a decimal point
            return NO;
        }
        
        NSString *newValue = [[textField text] stringByReplacingCharactersInRange:range withString:string];
        newValue = [[newValue componentsSeparatedByCharactersInSet:nonNumberSet] componentsJoinedByString:@""];
        
        if ([newValue rangeOfString:@"(\\d{1,}\\.){4}" options:NSRegularExpressionSearch].length > 0) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - 输入框为空ok键不激活
- (void)alertTextFieldDidChange:(NSNotification *)notification{
    NSLog(@"%@", notification.userInfo);
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        UIAlertAction *okAction = alertController.actions.firstObject;
        BOOL isEnableOK = YES;
        for (UITextField *textField in alertController.textFields) {
            if (textField.tag == TexTFieldIP) {
                if ([[textField text] rangeOfString:@"((2[0-4]\\d|25[0-5]|[01]?\\d\\d?)\\.){3}(2[0-4]\\d|25[0-5]|[01]?\\d\\d?)" options:NSRegularExpressionSearch].length == 0) {
                    isEnableOK = NO;
                }
            }   else {
                if ([textField text].length == 0) {
                    isEnableOK = NO;
                }
            }
        }
        okAction.enabled = isEnableOK;
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XTSStateCell *cell = (XTSStateCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *states = [[self.fetchedResultController fetchedObjects] lastObject];

    if ([[self.config headerInSection:indexPath.section] isEqualToString:@"模块指示灯"]) {
        NSString *stateString = [NSString stringWithFormat:@"%@", [states valueForKey:cell.key]];
        NSLog(@"%@", stateString);
        UIImage *image = [UIImage imageNamed:[stateString isEqualToString:@"启动"] || [stateString isEqualToString:@"0"] == NO ? @"红色按钮.jpg":@"黑色按钮.png"];
        [cell.stateImageView setImage:image];
        cell.label.text = [stateString isEqualToString:@"0"] == NO ? @"启动":@"关闭";
    }   else if ([[self.config headerInSection:indexPath.section] isEqualToString:@"压力室"])  {
        NSNumber *value = [states valueForKey:cell.key];
        NSLog(@"key: %@ ,value: %@", cell.key, value);
        cell.label.text = [NSString stringWithFormat:@"%.2f", [value floatValue]];
    } else {
        
    }
    
    return cell;
}

#pragma mark - StreamEventErrorOccurred Delegate
/*
 接受到的数据是josn数据，所以需要转换成字典才更好的操作
 1.josn数据转换成字典
 2.将状态数据写入数据库，利用键值对，键名关系我们在之前已经确定
 3.一旦保压时间到，就用警告视图提示
 4.更新视图
 */

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type{
     NSLog(@"ErrorOccurred :%@ ,type: %@",[error localizedDescription],type);
    if ([type isEqualToString:@"NetEventConnectOverTime"]) {
        self.title = @"连接超时 5秒后重连...";
//        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"连接服务器超时" message:@"请检查你的网络和服务器ip" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
//            //[self.refreshControl endRefreshing];
//        }];
//        [alertView addAction:okAction];
//        [[AppDelegate getCurrentVC] presentViewController:alertView animated:YES completion:nil];
    }
    //[self closeSocket];

}

-(void)streamEventOpenSucces {
    NSLog(@"Stream Open Succes！");
    self.title = @"已连接";
}

-(void)streamEventClose {
    NSLog(@"Stream Close！");
    //[self closeSocket];
    self.title = @"连接已关闭";


}

#pragma mark - 关闭socket
- (void)closeSocket {
    //断开socker
    self.socketer.errorDelegate = nil;
    self.socketer.dataDelegate = nil;
    //self.socketer = nil;
    self.title = @"连接已关闭";
}

- (void)connectSocket {
    self.socketer.errorDelegate = self;
    self.socketer.dataDelegate = self;
}

#pragma mark - StreamEventDataProcess Delegate

-(void)streamDataRecvSuccess:(NSData *)data {
    NSError *error_check_json;
    
    NSDictionary *revData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
     
    NSDictionary *state = [revData objectForKey:@"state"];
    NSLog(@"%@", state);
    NSManagedObject *object = [[self.fetchedResultController fetchedObjects] lastObject];
    
    for (NSString *QSYKey in [self.nameZonePair allKeys]) {
        NSString *XTSKey = [self.nameZonePair objectForKey:QSYKey];
        if ([state objectForKey:QSYKey] != nil) {
            [object setValue:[state objectForKey:QSYKey] forKey:XTSKey];
        }
    }
    
    NSError *error;
    if (![object.managedObjectContext save:&error]) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    BOOL timeout = [object valueForKey:XTSStateStableValveTimeout];
    
    if (timeout) {
        NSNumber *presure = [object valueForKey:XTSStateCurrentTargetPress];
        NSNumber *time =[object valueForKey:XTSStateRemainTime];
        NSNumber *rate = [object valueForKey:XTSStateCurrentChangeRate];
        NSString *title = [NSString stringWithFormat:@"保压时间到！"];
        NSString *message = [NSString stringWithFormat:@"气压值: %.2f kpa\n时间: %.2f 分钟\n速率: %.2f kpa/s", [presure floatValue], [time floatValue], [rate floatValue]];
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
        }];
        [alertView addAction:okAction];
        [[AppDelegate getCurrentVC] presentViewController:alertView
                                                 animated:YES
                                               completion:nil];
    }
    
    //[self closeSocket];
    [self.tableView reloadData];
}

@end
