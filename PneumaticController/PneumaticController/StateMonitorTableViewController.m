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
#import "AppDelegate.h"


#define XTSStateChangerate @"changerate"
#define XTSStateElectromagnet @"electromagnet"  //电磁铁
#define XTSStateHighPressureValve @"highpressurevalve"  //高压阀
#define XTSStateLowPressureValve @"lowpressurevalve"    //低压阀
#define XTSStatePressure @"pressure"                    //气压
#define XTSStateruntime @"runtime"                      //
#define XTSStateStableValve @"stablevalve"              //稳压阀
#define XTSStateTemperature @"temperature"              //温度
#define XTSStateVacuumpump @"vacuumpump"                //真空泵
#define XTSStateStableValveTimeout @"stablevalvetimeout"      //保压时间到
#define XTSStateUSB @"usb"                              //串口状态

#define QSYStateChangerate @"changerate"
#define QSYStateElectromagnet @"electromagnet"  //电磁铁
#define QSYStateHighPressureValve @"high_press"  //高压阀
#define QSYStateLowPressureValve @"lowp_press"    //低压阀
#define QSYStatePressure @"pressure"                    //气压
#define QSYStateruntime @"runtime"                      //
#define QSYStateStableValve @"press_remain"              //稳压阀
#define QSYStateTemperature @"temperature"              //温度
#define QSYStateVacuumpump @"pump"                //真空泵
#define QSYStateStableValveTimeout @"timeout"      //保压时间到
#define QSYStateUSB @"serial"                              //串口状态


#define IdentifierONorOFF(x) ([x isEqualToString:@"启动"]?@"红色按钮.jpg":@"黑色按钮.png")


@interface StateMonitorTableViewController (){
    MBProgressHUD *HUD; //菊花
    UIRefreshControl *refreshControl;
}
//@property (nonatomic,strong) ;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultController;
@property (nonatomic,strong) XTSSocketController *socketer;
@property (nonatomic, strong) NSDictionary *nameZonePair;//数据库键名和josn键名对应关系
@end

@implementation StateMonitorTableViewController
@synthesize fetchedResultController=_fetchedResultController;
//@synthesize refreshControl=_refreshControl;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // 由plist来确定每个cell的类型
    self.config=[[managedObjectConfiguration alloc] initWithResource:@"StateMonitorList"];
    self.navigationItem.title=@"未连接";
    
    // 导航栏左键为修改服务器ip，右键为更新按钮
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshState)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeServer)];
    
    // 下拉更新控件
    self.refreshControl=[[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新……"];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(refreshState) forControlEvents:UIControlEventValueChanged];
    
    // 先从数据库读取最近一次状态，如果没有状态，在数据库添加一个新的状态实例
    NSError *error;
    [self.fetchedResultController performFetch:&error];
    if ([[self.fetchedResultController fetchedObjects] count]==0) {
        NSManagedObjectContext *managedObjectContext=[self.fetchedResultController managedObjectContext];
        NSEntityDescription *entity=[[self.fetchedResultController fetchRequest] entity];
        NSManagedObject *newReciveSet=[NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                  inManagedObjectContext:managedObjectContext];
        NSError *error;
        
        if (![newReciveSet.managedObjectContext save:&error]) {
            
        }
    }
    
    //将服务器的josn键名和本地数据库联系起来
    [self setSocketJOSNKeyAndCoreDataKeyPair];
}

/*
 数据库键名最好是固定的，所以需要建立与josn键名的关系，即使josn键名改变也可进行较小的修改
 另外，解析的时候更方便进行键值存储
 */
-(void)setSocketJOSNKeyAndCoreDataKeyPair{
    NSArray *XTSNames=[NSArray arrayWithObjects://XTSStateChangerate,
                                                XTSStateElectromagnet,
                                                XTSStateHighPressureValve,
                                                XTSStateLowPressureValve,
                                                XTSStatePressure,
                                                //XTSStateruntime,
                                                XTSStateStableValve,
                                                XTSStateStableValveTimeout,
                                                XTSStateTemperature,
                                                XTSStateUSB,
                                                XTSStateVacuumpump, nil];
    NSArray *QSYNames=[NSArray arrayWithObjects://QSYStateChangerate,
                                                QSYStateElectromagnet,
                                                QSYStateHighPressureValve,
                                                QSYStateLowPressureValve,
                                                QSYStatePressure,
                                                //QSYStateruntime,
                                                QSYStateStableValve,
                                                QSYStateStableValveTimeout,
                                                QSYStateTemperature,
                                                QSYStateUSB,
                                                QSYStateVacuumpump, nil];
    NSDictionary *nameZonePair=[NSDictionary dictionaryWithObjects:XTSNames forKeys:QSYNames];
    self.nameZonePair=nameZonePair;
}

/*
 fetchedResultController的getter方法，从数据库中读取我们需要的实体需要以下几个步骤（这里要取的是状态数据，也就是Recive实体）：
 1.获得数据库托管上下文 （NSManagedObjectContext），并设置获取请求（NSFetchRequest），不过要为它提供一个 NSEntityDescription，指定希望检索名为“Recive”的多个对象实体。还需要 NSSortDescriptor 提供检索结果的排序，这里我们用压力变化速率来排序，我们当前并不需要排序，只是使用过程需要这个参数
 2.调用initWithFetchRequest:managedObjectContext:sectionNameKeyPath:cacheName:方法进行检索
 
 */
-(NSFetchedResultsController *)fetchedResultController{
    if (_fetchedResultController != nil) {
        return _fetchedResultController;
    }
    NSFetchRequest *fetchReqest=[[NSFetchRequest alloc] init];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=[appDelegate managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Recive"
                                            inManagedObjectContext:managedObjectContext];
    
    [fetchReqest setEntity:entity];
    //NSError *error;
    //NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchReqest error:&error];
    [fetchReqest setFetchBatchSize:20];
    
    NSString *sectionKey=@"changerate";
    
    NSSortDescriptor *sortDescriptor1=[[NSSortDescriptor alloc] initWithKey:@"changerate"
                                                                  ascending:YES];
    NSArray *sortDescriptiors=[[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchReqest setSortDescriptors:sortDescriptiors];
    
    _fetchedResultController=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchReqest
                                                                 managedObjectContext:managedObjectContext
                                                                   sectionNameKeyPath:sectionKey
                                                                            cacheName:@"Recive"];
    
    _fetchedResultController.delegate=self;
    //NSError *error = NULL;
    /*if (![_fetchedResultController performFetch:&error]) {
     NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
     abort();
     }*/
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
-(void)refreshState{
    //NSLog(@"%lu",[[self.fetchedResultController fetchedObjects] count]);
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSString *ip=[userDefaults valueForKey:kIPAdressKey];
   // temp isEqualToString:<#(nonnull NSString *)#>
   // NSLog(@"ip:%d",temp.length);
    if (ip.length==0) {
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"刷新失败" message:@"请先设置你的服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
        
        return;
    }
    /*if (![self initDefaultsState]) {
        NSLog(@"initDefaultsState failed!");
        return ;
    }*/
    
    //XTSSocketController *socketer=[[XTSSocketController alloc] init];
    if (self.socketer==nil) {
       self.socketer=[[XTSSocketController alloc] init];
    }
    self.socketer.flag=1;
    //char *str="hello world!";
    //NSNumber *pressure=[[NSNumber alloc] initWithFloat:105.0];
    //NSNumber *timeout=[[NSNumber alloc] initWithChar:5];
    NSDictionary *keysAndValues;//=[NSDictionary dictionaryWithObjectsAndKeys:pressure,@"pressure",timeout,@"timeout", nil];
    XTSDataMode mode=XTSDataStateRequireMode;
    //NSMutableData *sendeData=[[NSData alloc] init];
    //soketer.sendData=sendeData;
    _socketer.errorDelegate=self;
    _socketer.dataDelegate=self;
    //self.socketer=soketer;
    [_socketer initNetworkCommunication:keysAndValues hostIP:ip];
    if (![_socketer sendDataWithMode:mode dataPack:keysAndValues]) {
        NSLog(@"set send data failed!");
        /*
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"连接失败" message:@"请检查你的网络或者服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];*/
    }else{
        //[self.tableView reloadData];
    }
    
    //[self.refreshControl endRefreshing];
}

/*
 测试用例
 */
-(BOOL)initDefaultsState{
    NSManagedObject *stateObject=[self.fetchedResultController.fetchedObjects lastObject];
    
    NSString *electromagnet=@"未启动";//[stateObject valueForKey:XTSStateElectromagnet];
    NSString *highpressurevalve=@"启动";//[stateObject valueForKey:XTSStateHighPressureValve];
    NSString *lowpressurevalve=@"启动";//[stateObject valueForKey:XTSStateLowPressureValve];
    NSString *pressure=@"1000hpa";//[stateObject valueForKey:XTSStatePressure];
    NSString *stablevalve=@"启动";//[stateObject valueForKey:XTSStateElectromagnet];
    NSString *temperature=@"40度";//[stateObject valueForKey:XTSStateTemperature];
    NSString *vacuumpump=@"启动";//[stateObject valueForKey:XTSStateStableValveTimeout];
    NSString *stablevalvetimeout=@"否";//[stateObject valueForKey:XTSStateElectromagnet];
    NSString *usb=@"正常";//[stateObject valueForKey:XTSStateUSB];
    NSString *changerate=@"100p/s";
    
    [stateObject setValue:electromagnet forKey:XTSStateElectromagnet];
    [stateObject setValue:highpressurevalve forKey:XTSStateHighPressureValve];
    [stateObject setValue:lowpressurevalve forKey:XTSStateLowPressureValve];
    [stateObject setValue:pressure forKey:XTSStatePressure];
    [stateObject setValue:stablevalve forKey:XTSStateStableValve];
    [stateObject setValue:temperature forKey:XTSStateTemperature];
    [stateObject setValue:vacuumpump forKey:XTSStateVacuumpump];
    [stateObject setValue:stablevalvetimeout forKey:XTSStateStableValveTimeout];
    [stateObject setValue:usb forKey:XTSStateUSB];
    [stateObject setValue:changerate forKey:XTSStateChangerate];
    
    NSError *error;
    BOOL saveState=[self.fetchedResultController.managedObjectContext save:&error];
    if (!saveState) {
        NSLog(@"%@",[error localizedDescription]);
        //exit(<#int#>)
    }
    
    return saveState;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 变更ip方法。通过警告视图中的文本框获得用户指定的ip值，存入NSUserDefaults
 */

-(void)changeServer{
    
    NSString *title=@"请设置你的服务器ip";
    NSString *message;
    //对话框弹出
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSomeLog:) name:@"GOOD" object:nil];
    
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                //按下ok后准备菊花显示，直到服务器通讯的结果返回
        /*
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.delegate = self;
                HUD.labelText = @"正在设置";
                HUD.dimBackground = YES;
        [HUD showWhileExecuting:@selector(configIP:) onTarget:self withObject:alertController.textFields.firstObject.text animated:YES];*/
        [self configIP:alertController.textFields.firstObject.text];
    }];
    
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //添加ok、cancel和输入文本框
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
        NSString *titleIP=[userDefaults valueForKey:kIPAdressKey];
        textField.text=titleIP;
        textField.keyboardType=UIKeyboardTypeDecimalPad;
        //textField.ke
        //value=[textField.text mutableCopy];
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)configIP:(NSString *)text{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:text forKey:kIPAdressKey];

}

#pragma mark - Table view data source
//@synthesize fetchedResultController = _fetchedResultController;

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
 
 // Configure the cell...
 
 return cell;
 }
 */

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 我们需要重载表视图的cell的更新方法，父类原来的方法还是要执行的，要修改的是右侧启动状态文字和模块指示灯的显示，因为除了模块指示灯类的cell才有知识灯显示。
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XTSStateCell *cell=[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell...
    NSManagedObject *states=[[self.fetchedResultController fetchedObjects] lastObject];
    NSString *stateString=[NSString stringWithFormat:@"%@",[states valueForKey:cell.key]];
    cell.label.text=stateString;
    
    if ([[self.config headerInSection:indexPath.section] isEqualToString:@"模块指示灯"]) {
        UIImage *image=[UIImage imageNamed:[stateString isEqualToString:@"启动"]||[stateString isEqualToString:@"正常"]==YES ? @"红色按钮.jpg":@"黑色按钮.png"];
        cell.stateImage=image;
        cell.stateImageView=[[UIImageView alloc] initWithFrame:CGRectMake(270.0,7.0, 25, 25)];
        [cell.stateImageView setImage:cell.stateImage];
        [cell.contentView addSubview:cell.stateImageView];
    }
    
    return cell;
}

/*-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView
 editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
 return editStyle;
 }*/

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
/*
 - (void)tableView:(UITableView *)tableView
 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath]
 withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 }
 /////////////////////////p207 p213
 
 }*/

#pragma mark - StreamEventErrorOccurred Delegate

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type{
     //NSLog(@"ErrorOccurred :%@ ,type: %@",[error localizedDescription],type);
    //连接超时
    if ([type isEqualToString:@"NetEventConnectOverTime"]) {
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"连接服务器超时" message:@"请检查你的网络和服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //[self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
    [self.refreshControl endRefreshing];
}

-(void)streamEventOpenSucces{
    NSLog(@"Stream Open Succes！");
}

-(void)streamEventClose{
    NSLog(@"Stream Close！");
    [self.refreshControl endRefreshing];
}

#pragma mark - StreamEventDataProcess Delegate
/*
 接受到的数据是josn数据，所以需要转换成字典才更好的操作
 1.josn数据转换成字典
 2.将状态数据写入数据库，利用键值对，键名关系我们在之前已经确定
 3.一旦保压时间到，就用警告视图提示
 4.更新视图
 */
-(void)streamDataRecvSuccess:(NSData *)data{
    NSError *error_check_json;
    NSDictionary *revData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
    NSDictionary *state=[revData objectForKey:@"state"];
    NSManagedObject *object=[[self.fetchedResultController fetchedObjects] lastObject];
    
    for (NSString *QSYKey in [self.nameZonePair allKeys]) {
        NSString *XTSKey=[self.nameZonePair objectForKey:QSYKey];
        [object setValue:[state objectForKey:QSYKey] forKey:XTSKey];
    }
    
    NSError *error;
    if (![object.managedObjectContext save:&error]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    BOOL timeout=[object valueForKey:XTSStateStableValveTimeout];
    if (timeout==YES) {
        NSNumber *presure=[object valueForKey:XTSStatePressure];
        //NSNumber *time=[object valueForKey:xts];
        NSString *title=[NSString stringWithFormat:@"保压时间到！"];
        NSString *message=[NSString stringWithFormat:@"气压值：%.2f",[presure floatValue]];
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //[self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
        
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

@end
