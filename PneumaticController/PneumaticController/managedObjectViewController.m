//
//  managedObjectViewController.m
//  
//
//  Created by virus1993 on 15/12/3.
//
//

#import "managedObjectViewController.h"
#import "managedObjectConfiguration.h"
#import "AppDelegate.h"
#import "XTSInfoCell.h"
#import "XTSStateCell.h"
#import "XTSAutoSetCell.h"

@interface managedObjectViewController ()
//@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultController;
@end


@implementation managedObjectViewController
#pragma mark - Table view data source
//@synthesize fetchedResultController = _fetchedResultController;

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
    
    NSString *cellClassname = [self.config cellClassnameForIndexPath:indexPath];
    
    XTSInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellClassname];
    
    //cellState=(cell!=nil)?@"not nil":@"nil";
    
    if (cell == nil) {
        Class cellClass=NSClassFromString(cellClassname);
        cell = [cellClass alloc];
        cell = [cell initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellClassname];
    }
    
    cell.key = [self.config  attributeKeyForIndexPath:indexPath];
    cell.textLabel.text = [self.config labelForIndexPath:indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    NSArray *values = [self.config valuesForIndexPath:indexPath];
    //NSLog(@"\nCell Name: \n\t\t%@\n\t\t%@\n\t\tlabel text: %@\n\t\tconfig attributeKey: %@\n\t\tvalue: %@\n",cellClassname,cellState,[self.config labelForIndexPath:indexPath],[self.config attributeKeyForIndexPath:indexPath],cell.value);
    
    if (values != nil) {
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error saving entity",@"Error savong entity")
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



@end
