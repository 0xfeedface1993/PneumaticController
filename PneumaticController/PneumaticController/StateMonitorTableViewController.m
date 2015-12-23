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
@property (nonatomic, strong) NSDictionary *nameZonePair;
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
    self.config=[[managedObjectConfiguration alloc] initWithResource:@"StateMonitorList"];
    self.navigationItem.title=@"未连接";
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshState)];
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(changeServer)];
    self.refreshControl=[[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新……"];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(refreshState) forControlEvents:UIControlEventValueChanged];
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
    [self setSocketJOSNKeyAndCoreDataKeyPair];
}

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
