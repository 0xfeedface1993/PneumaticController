//
//  StateMonitorTableViewController.m
//  PneumaticController
//
//  Created by virus1993 on 15/11/24.
//  Copyright © 2015年 virus1993. All rights reserved.
//

#import "StateMonitorTableViewController.h"
#import "managedObjectConfiguration.h"
#import "AppDelegate.h"
#import "XTSInfoCell.h"
#import "XTSStateCell.h"

@interface StateMonitorTableViewController (){
    MBProgressHUD *HUD; //菊花
}
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultController;
@end

@implementation StateMonitorTableViewController
@synthesize fetchedResultController=_fetchedResultController;

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
    //self.navigationController.navigationBar.tintColor =[UIColor redColor];
    //Fetch any existing entitys
    //NSError *error;
    //UINavigationController *navigationController=[[UINavigationController alloc] init];
    //navigationControllerTop=navigationController;
    //[navigationControllerTop pushViewController:self animated:YES];
    //[self.view addSubview:navigationControllerTop.view];
    
    //[self.navigationController setToolbarHidden:YES animated:YES];
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                               //target:self
                                                                               //action:@selector(gotoThridView:)];
    //toolBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0,0, self.view.frame.size.width, 44.0)];
   // [toolBar setBarStyle:UIBarStyleDefault];//self.view.frame.size.height - toolBar.frame.size.height - 44.0
    //toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    //[toolBar setItems:[NSArray arrayWithObject:addButton]];
   // [self.view addSubview:toolBar];
   // CGPoint origin=CGPointMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y+toolBar.frame.origin.y);
    //[self.tableView setFrame:CGRectMake(origin.x, origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height)];

    //self.tableView.tableHeaderView=
    //UINavigationController *navigationController=[[UINavigationController alloc] ini];
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    //self.navigationController.navigationBarHidden=YES;

    /*
    if (![[self fetchedResultController] performFetch:&error]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error loading data",@"Error loading data")
                                                      message:[NSString stringWithFormat:NSLocalizedString(@"Error was:%@, quitting.", @"Error was:%@, quitting."),[error localizedDescription]]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                            otherButtonTitles:nil];
        [alert show];
    }*/
}
/*
-(NSFetchedResultsController *)fetchedResultController{
    if (_fetchedResultController != nil) {
        return _fetchedResultController;
    }
    NSFetchRequest *fetchReqest=[[NSFetchRequest alloc] init];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext=[appDelegate managedObjectContext];
    NSEntityDescription *entity=[NSEntityDescription entityForName:@"Hero" inManagedObjectContext:managedObjectContext];
    
    [fetchReqest setEntity:entity];
    [fetchReqest setFetchBatchSize:20];
    
    NSString *sectionKey=nil;
    
    NSSortDescriptor *sortDescriptor1=[[NSSortDescriptor alloc] initWithKey:@"secretIdentity"
                                                                          ascending:YES];
    NSSortDescriptor *sortDescriptor2=[[NSSortDescriptor alloc] initWithKey:@"name"
                                                                          ascending:YES];
    NSArray *sortDescriptors=[[NSArray alloc] initWithObjects:sortDescriptor1, sortDescriptor2, nil];
    [fetchReqest setSortDescriptors:sortDescriptors];
            sectionKey=@"secretIdentity";
    
    _fetchedResultController=[[NSFetchedResultsController alloc] initWithFetchRequest:fetchReqest
                                                                 managedObjectContext:managedObjectContext
                                                                   sectionNameKeyPath:sectionKey
                                                                            cacheName:@"Hero"];
    _fetchedResultController.delegate=self;
    return _fetchedResultController;
}*/

-(void)refreshState{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
    return [self.config numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
    NSInteger rowCount=[self.config numberOfRowsInSection:section];
    return rowCount;
}

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
    //SuperDBEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SuperDBEditCell" ];//forIndexPath:indexPath];
    
    // Configure the cell...
    
    //cell.textLabel.text=self.sections cvcv
    
    //********************************p113 p199
    
    
    //NSString *cellState;
    
    NSString *cellClassname=[self.config cellClassnameForIndexPath:indexPath];
    
    XTSInfoCell *cell=[tableView dequeueReusableCellWithIdentifier:cellClassname];
    
    //cellState=(cell!=nil)?@"not nil":@"nil";
    
    if (cell==nil) {
        Class cellClass=NSClassFromString(cellClassname);
        cell = [cellClass alloc];
        cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellClassname];
    }
    
    cell.key=[self.config  attributeKeyForIndexPath:indexPath];
    cell.textLabel.text=[self.config labelForIndexPath:indexPath];
    cell.textLabel.textAlignment=NSTextAlignmentLeft;
    
    NSArray *values=[self.config valuesForIndexPath:indexPath];
    //NSLog(@"\nCell Name: \n\t\t%@\n\t\t%@\n\t\tlabel text: %@\n\t\tconfig attributeKey: %@\n\t\tvalue: %@\n",cellClassname,cellState,[self.config labelForIndexPath:indexPath],[self.config attributeKeyForIndexPath:indexPath],cell.value);
    
    if (values!=nil) {
        //[cell performSelector:@selector(setValues:) withObject:values];
    }
    
    return cell;
}

/*-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return editStyle;
}*/

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.config headerInSection:section];
}
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

/*

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

-(void)saveManagedObjectContext{
    NSError *error;//=nil;
    if (![self.managedObject.managedObjectContext save:&error]) {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving entity",@"Error savong entity")
                                                      message:[NSString stringWithFormat:NSLocalizedString(@"Error was:%@, qutting.", @"Error was:%@, qutting.")]
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Aw, Nuts", @"Aw, Nuts")
                                            otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Instance Methods
-(void)save{
    //**********************************p115
    [self setEditing:NO animated:YES];
    for (XTSInfoCell *cell in [self.tableView visibleCells]) {
        //if ([cell isEditable]) {
            [self.managedObject setValue:[cell value] forKey:[cell key]];
        //}
        //the Birthdate should be NSDate type,but we save it to to String type,just for easy
    }
    [self saveManagedObjectContext];
    [self.tableView reloadData];
}
-(void)cancel{
    [self setEditing:NO animated:YES];
}

-(void)changeServer{
    
    NSString *title=@"请设置你的服务器ip";
    NSString *message;
    //对话框弹出
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeSomeLog:) name:@"GOOD" object:nil];
    
    UIAlertAction *okAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
       
                //按下ok后准备菊花显示，直到服务器通讯的结果返回
                HUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:HUD];
                HUD.delegate = self;
                HUD.labelText = @"正在设置";
                HUD.dimBackground = YES;
        [HUD showWhileExecuting:@selector(configIP:) onTarget:self withObject:alertController.textFields.firstObject.text animated:YES];
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

-(void)configIP:(NSString *)text{
    
}
@end
