//
//  AutoModeViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/12/3.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "AutoModeViewController.h"
#import "managedObjectConfiguration.h"
//#import "ModifyViewController.h"
#import "MBProgressHUD.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "XTSAutoSetCell.h"
//#import "XTSSocketController.h"

enum TextFieldType{
    XTSTimeTextField=11,
    XTSPressureTextField=22
   // XTSTextField=33
};

@interface AutoModeViewController (){
    MBProgressHUD *HUD; //菊花
}
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultController;
@property (nonatomic, strong) XTSSocketController *socker;
@end

@implementation AutoModeViewController
@synthesize fetchedResultController=_fetchedResultController;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.config=[[managedObjectConfiguration alloc] initWithResource:@"AutoModeTableList"];
    //添加返回、上传、添加按钮
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone  target:self action:@selector(backModeView)];
    UIBarButtonItem *itemAdd=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSerilSet)];
    UIBarButtonItem *itemUpload=[[UIBarButtonItem alloc] initWithTitle:@"上传" style:UIBarButtonItemStyleDone  target:self action:@selector(uploadSet)];
    NSArray *arry=[[NSArray alloc] initWithObjects:itemAdd,itemUpload, nil];
    
    self.navigationItem.rightBarButtonItems=arry;
    self.navigationItem.title=@"自动模式";
    //self.tableView.rowHeight=50.0;
    [self.tableView setEditing:YES animated:YES];
    //
    
    //读取数据库中最近的修改的序列
    NSError *error;
    if (![[self fetchedResultController] performFetch:&error]) {
        /*UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data",@"Error loading data")
                                                      message:[NSString stringWithFormat:NSLocalizedString(@"Error was:%@, quitting.", @"Error was:%@, quitting."),[error localizedDescription]]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                            otherButtonTitles:nil];
        [alert show];*/
    }

   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 返回上一个视图。要断开socket连接，dismissViewControllerAnimated:completion:方法会释放掉自己，其它方法可能只是入视图栈，会导致多个AutoModeViewController实例存在
 */
-(void)backModeView{
    //[self.navigationController popViewControllerAnimated:YES];
    [self.socker close];
    self.socker=nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
 添加序列项。
 1.数据库中添加一个序列实体modeset，此时只是在托管上下文中添加，并没有持久化，持久化发生在用户确认之后，否则不保存
 2.使用模态的警告视图获得用户输入的压力值和保压时间
 3.存入数据库，操作在确定按键的回调函数块内实现。coredata只支持cocoa类的存储，不支持基本数据类型的存储，所以需要NSNumber来维护int这些基本类型
 */
-(void)addSerilSet{
    NSString *title=@"添加序列项";
    NSString *message;
    //对话框弹出
    NSManagedObjectContext *managedObjectContext=[self.fetchedResultController managedObjectContext];
    NSEntityDescription *entity=[[self.fetchedResultController fetchRequest] entity];
    //[NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:managedObjectContext];
    NSManagedObject *newModeSet=[NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                              inManagedObjectContext:managedObjectContext];
    
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSomeLog:) name:@"GOOD" object:nil];
    
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        int timeStable = 0;
        float pressure = 0.0;
        for (UITextField *textField in alertController.textFields) {
            if (textField.tag==XTSTimeTextField) {
                timeStable=textField.text.intValue;
            }
            if(textField.tag==XTSPressureTextField){
                pressure=textField.text.intValue;
            }
        }
                /*
        for (XTSAutoSetCell  *cell in [self.tableView visibleCells]) {
            [self.managedObject setValue:[cell value] forKey:[cell key]];
            //the Birthdate should be NSDate type,but we save it to to String type,just for easy
        }*/
        //[self save];
        //[self.tableView reloadData];
       // NSError *errorx;
        //if (![[self fetchedResultController] performFetch:&errorx]) {
            
        //}
        
        int number=[[self.fetchedResultController fetchedObjects] count];
        //[newModeSet setValue:[[NSNumber alloc] initWithInt:timeStable] forKey:@"time"];
        //[newModeSet setValue:[[NSNumber alloc] initWithFloat:pressure] forKey:@"pressure"];
        //[newModeSet setValue:[[NSNumber alloc] initWithInt:number] forKey:@"number"];
        [newModeSet setValue:[[NSNumber alloc] initWithInt:timeStable] forKey:@"time"];
        [newModeSet setValue:[[NSNumber alloc] initWithFloat:pressure] forKey:@"pressure"];
        [newModeSet setValue:[[NSNumber alloc] initWithInt:number] forKey:@"number"];
        //NSLog(@"%d",[managedObjectContext hasChanges]);
        NSError *error;
        if (![newModeSet.managedObjectContext save:&error]) {
           /* UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving entity", @"Error saving entity")
                                                          message:[NSString stringWithFormat:NSLocalizedString(@"Error was:%@,quitting.", @"Error was:%@,quitting."),[error localizedDescription]]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                                otherButtonTitles:nil];
            [alert show];*/
        }
        
        //NSManagedObject *aModeSet=[[self.fetchedResultController fetchedObjects] lastObject];
        
        //NSLog(@"\n entity %@, number %@,time %@,pressure %@\n",[aModeSet.entity name],[aModeSet valueForKey:@"number"],[aModeSet valueForKey:@"time"],[aModeSet valueForKey:@"pressure"]);
        
        //[self.fetchedResultController performFetch:&error];
        
       //[self.tableView reloadData];
        
        
        
    }];
    
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    //时间文本框和气压值文本框由tag来区分
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder=@"气压值";
        textField.keyboardType=UIKeyboardTypeDecimalPad;
        textField.tag=XTSPressureTextField;
        //textField.ke
        //value=[textField.text mutableCopy];
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder=@"时间";
        textField.keyboardType=UIKeyboardTypeDecimalPad;
        textField.tag=XTSTimeTextField;
        //textField.ke
        //value=[textField.text mutableCopy];
    }];
    
    //添加ok、cancel和输入文本框
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*
 上传数据。因为我们数据库存的只是序列，而且都是cocoa的类，不能用于与服务器数据交换，所以需要转换成josn数据，通过socket传送自动模式数据。
 1.检查是否ip为空，空着提示出错后面的代码不执行
 2.准备等待界面
 3.从数据库中取出序列，转化为字典，再交由socket类打包为自动模式上传数据
 4.实例化socket，设置为自动模式数据上传模式，上传数据
 */
-(void)uploadSet{
    NSString *ip=[[NSUserDefaults standardUserDefaults] valueForKey:@"ip"];
    if ([[self.fetchedResultController fetchedObjects] count]==0||[ip length]==0) {
        return;
    }
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
//    HUD.delegate = self;
    HUD.labelText = @"正在上传";
    HUD.dimBackground = YES;
    [HUD show:YES];
    //[HUD showWhileExecuting:@selector(packDataUp) onTarget:self withObject:nil animated:YES];
    [self packDataUp];
}

-(void)packDataUp{
    NSArray *modeSets=[self.fetchedResultController fetchedObjects];
    NSMutableArray *array=[[NSMutableArray alloc] init];
    for (NSManagedObject *aModeSet in modeSets) {
        NSNumber *time=[aModeSet valueForKey:@"time"];
        NSNumber *number=[aModeSet valueForKey:@"number"];
        NSNumber *pressure=[aModeSet valueForKey:@"pressure"];
        NSDictionary *set=[NSDictionary dictionaryWithObjectsAndKeys:time,@"time",number,@"number",pressure,@"pressure", nil];
        [array addObject:set];
    }
   // NSSortDescriptor *sortDescriptor=[NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    //[array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

    if (self.socker==nil) {
        _socker=[[XTSSocketController alloc] init];
    }
    _socker.flag=1;
    _socker.errorDelegate=self;
    _socker.dataDelegate=self;
    NSString *ip=[[NSUserDefaults standardUserDefaults] valueForKey:@"ip"];
    [_socker initNetworkCommunication:nil hostIP:ip];
    NSDictionary *dataPack=[self.socker packSendData:modeSets WithMode:XTSDataAutoMode];
    
    if (![_socker sendDataWithMode:XTSDataAutoMode dataPack:dataPack]) {
        NSLog(@"upload failed!");
    }
}

/*
 fetchedResultController的getter方法，从数据库中读取我们需要的实体需要以下几个步骤（这里要取的是状态数据，也就是Recive实体）：
 1.获得数据库托管上下文 （NSManagedObjectContext），并设置获取请求（NSFetchRequest），不过要为它提供一个 NSEntityDescription，指定希望检索名为“ModeSet”的多个对象实体。还需要 NSSortDescriptor 提供检索结果的排序，这里我们用序列号来排序
 2.调用initWithFetchRequest:managedObjectContext:sectionNameKeyPath:cacheName:方法进行检索
 
 */
-(NSFetchedResultsController *)fetchedResultController{
    if (_fetchedResultController != nil) {
        return _fetchedResultController;
    }
    NSFetchRequest *fetchReqest=[[NSFetchRequest alloc] init];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=[appDelegate managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"ModeSet" inManagedObjectContext:managedObjectContext];
    
    [fetchReqest setEntity:entity];
    //NSError *error;
    //NSArray *fetchedObjects = [managedObjectContext executeFetchRequest:fetchReqest error:&error];
    [fetchReqest setFetchBatchSize:20];
    
    NSString *sectionKey=@"number";
    
    NSSortDescriptor *sortDescriptor1=[[NSSortDescriptor alloc] initWithKey:@"number"
                                                                  ascending:YES];
    NSArray *sortDescriptiors=[[NSArray alloc] initWithObjects:sortDescriptor1, nil];
    [fetchReqest setSortDescriptors:sortDescriptiors];
    
    _fetchedResultController=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchReqest
                                                                 managedObjectContext:managedObjectContext
                                                                   sectionNameKeyPath:sectionKey
                                                                            cacheName:@"ModeSet"];
    
    _fetchedResultController.delegate=self;
    //NSError *error = NULL;
    /*if (![_fetchedResultController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }*/
    return _fetchedResultController;
}

#pragma mark - TableView Delegate

/*
             ______________________
 cell样式为：｜第0项   1000hpa   5min｜
            
 */

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier=@"XTSAutoSetCell";
    XTSAutoSetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[XTSAutoSetCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...

    NSManagedObject *aModeSet=[self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.row]];

    NSNumber *time=[aModeSet valueForKey:@"time"];
    NSNumber *number=[aModeSet valueForKey:@"number"];
    NSNumber *pressure=[aModeSet valueForKey:@"pressure"];
    //NSLog(@"\nnumber %@,time %@,pressure %@\n",[aModeSet valueForKey:@"number"],[aModeSet valueForKey:@"time"],[aModeSet valueForKey:@"pressure"]);
    
    if (aModeSet==nil) {
        return cell;
    }
     
    
    cell.textLabel.text=[NSString stringWithFormat:@"第%d项",[number intValue]];
    cell.textLabel.textAlignment=NSTextAlignmentLeft;
    cell.label.text=[NSString stringWithFormat:@"%d min",[time intValue]];
    cell.pressure.textAlignment=NSTextAlignmentLeft;
    cell.pressure.text=[NSString stringWithFormat:@"%.2f hPa",[pressure floatValue]];
    //[cell set]
    //cell.showsReorderControl=NO;
    return cell;
}

/*
 序列项数即是能检索到的实体数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete implementation, return the number of rows
    //NSInteger count=[[[self.fetchedResultController sections] objectAtIndex:section] numberOfObjects];
    NSInteger count=[[self.fetchedResultController sections] count];
    NSLog(@"rows %ld in section %ld",section,count);
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //#warning Incomplete implementation, return the number of sections
    //NSInteger count=[[self.fetchedResultController sections] count];
   // NSLog(@"section: %ld",(long)count);
    return 1;
}

#pragma mark - UITableView Data Delegate
/*
 这是一个高级功能，即删除序列和交换序列功能。
 1.删除序列。
 （1）首先获得对应序列的托管对象（NSManagedObject）和托管上下文（NSManagedObjectContext），在托管上下文删除该脱端对象。
 （2）对其它托管对象，也就是序列重新排序
 （3）保存托管上下文，即持久化
 （4）更新视图
 2.交换序列。
 （1）取得两个交换序列的托管对象（NSManagedObject）和托管上下文（NSManagedObjectContext）
 （2）取出两个托管对象即序列的序列号 "number"，交换序列号。表视图的排序是根据检索的结果，但是检索条件是根据序列号排序，所以只需要交换序列号，再次检索的时候检索器会自动排序
 （3）保存托管上下文，即持久化
 （4）更新视图
 */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        
        NSError *error;
        NSManagedObject *aModeSet=[self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.section inSection:0]];
        NSManagedObjectContext *managedContext=self.fetchedResultController.managedObjectContext;
        int deleteNumber=[[aModeSet valueForKey:@"number"] intValue];
        [managedContext deleteObject:aModeSet];
        [managedContext save:&error];
        
        for (NSManagedObject *object in [self.fetchedResultController fetchedObjects]) {
            NSNumber *number=[object valueForKey:@"number"];
            if ([number intValue]>deleteNumber) {
                number=[NSNumber numberWithInt:[number intValue]-1];
                [object setValue:number forKey:@"number"];
            }
        }
        
        [managedContext save:&error];
        [self.tableView reloadData];
    }
    if (editingStyle==UITableViewCellEditingStyleInsert) {
        
    }
    if (editingStyle==UITableViewCellEditingStyleNone) {
        
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setEditing:YES animated:YES];
    return UITableViewCellEditingStyleDelete;
}
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    if (indexPath.row>=[self.fetchedResultController.fetchedObjects count]) {
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    NSLog(@"\nsourceIndexPath section %ld row %ld,\ndestinationIndexPath section %ld row %ld",(long)sourceIndexPath.section,(long)sourceIndexPath.row,(long)destinationIndexPath.section,(long)destinationIndexPath.row);
    int sourceNumber;
    int destinationNumber;
    int temp;

    NSManagedObject *sourceModeSet=[self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sourceIndexPath.row]];
    NSManagedObject *destinationModeSet;
    if (destinationIndexPath.section<[[self.fetchedResultController sections] count]) {
    destinationModeSet=[self.fetchedResultController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:destinationIndexPath.row]];
    }else{
        
    }
    
    NSManagedObjectContext *managedContext=self.fetchedResultController.managedObjectContext;
    
    //if (destinationModeSet!=nil) {
        sourceNumber=[[sourceModeSet valueForKey:@"number"] intValue];
        destinationNumber=[[destinationModeSet valueForKey:@"number"] intValue];
        
        temp=sourceNumber;
        sourceNumber=destinationNumber;
        destinationNumber=temp;
    //}else{
        
    //}
    
    
    NSError *error;
    [sourceModeSet setValue:[NSNumber numberWithInt:sourceNumber]  forKey:@"number"];
    //[managedContext save:&error];
    [destinationModeSet setValue:[NSNumber numberWithInt:destinationNumber] forKey:@"number"];
    [managedContext save:&error];
    
    //NSManagedObject *source=[self.fetchedResultController objectAtIndexPath:sourceIndexPath];
   //NSManagedObject *destination=[self.fetchedResultController objectAtIndexPath:destinationIndexPath];
    //NSNumber *sN=[source valueForKey:@"number"];
    //NSNumber *dN=[destination valueForKey:@"number"];
    
    
    //NSLog(@"\nsource number:%@,destination number:%@\n",sN,dN);
    //[self.fetchedResultController performFetch:&error];
    
    //NSError *error;
    //[managedContext save:&error];
    //[self.tableView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - NSFetchedResultsControllerDelegate Methods

/*
 当检索器检索结果有变化时，如删除、添加操作后，会调用如下代码进行表视图的更新
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id < NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    //[self.tableView beginUpdates];
   // NSLog(@"\nsectionIndex %@",sectionIndex);
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sectionIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sectionIndex inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            NSLog(@"NSFetchedResultsChangeMove");
            break;
        case NSFetchedResultsChangeMove:
            NSLog(@"NSFetchedResultsChangeUpdate");
            break;
        default:
            break;
    }
    //[self.tableView endUpdates];
}
/*
- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    //[self.tableView beginUpdates];
    //NSLog(@"\natIndexPath %@,\nnewIndexPath %@",indexPath,newIndexPath);
    
    //[self.tableView endUpdates];
}*/


#pragma mark - StreamEventErrorOccurred Delegate

-(void)streamEventErrorOccurredAction:(NSError *)error type:(NSString *)type{
   // NSLog(@"ErrorOccurred :%@ ,type: %@",[error localizedDescription],type);
    //连接超时
    [HUD hide:NO];
    if ([type isEqualToString:@"NetEventConnectOverTime"]) {
        UIAlertController *alertView=[UIAlertController alertControllerWithTitle:@"连接服务器超时" message:@"请检查你的网络和服务器ip" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            //[self.refreshControl endRefreshing];
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
    }
    //[self.refreshControl endRefreshing];
}

-(void)streamEventOpenSucces{
    NSLog(@"Stream Open Succes！");
}

-(void)streamEventClose{
    [HUD hide:NO];
    NSLog(@"Stream Close！");
    //[self.refreshControl endRefreshing];
}

#pragma mark - StreamEventDataProcess Delegate

-(void)streamDataRecvSuccess:(NSData *)data{
    //接受到服务器响应
    [HUD hide:NO];
    //NSError *error_check_json;
    //NSDictionary *revData=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error_check_json];
    //NSDictionary *state=[revData objectForKey:@"state"];
    //NSManagedObject *object=[[self.fetchedResultController fetchedObjects] lastObject];
}
@end
