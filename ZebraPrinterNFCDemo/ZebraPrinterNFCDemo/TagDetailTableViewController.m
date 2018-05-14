//
//  TagContentsTableViewController.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/19/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "TagDetailTableViewController.h"
#import "TagDetailTableViewCell.h"
#import "PrinterStatusViewController.h"
#import "Util.h"

@interface TagDetailTableViewController ()

@property (strong, nonatomic) NSString *selectedPrinterSN;
@property (strong, nonatomic) NSMutableDictionary *printer;
@property (strong, nonatomic) NSArray *tagElem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *connectBTClassic;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *connectBTLE;


@end

@implementation TagDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the below variables with the value from the touched tag.
    self.selectedPrinterSN = self.scannedTagsTVC.nfcPrinterSerialNumbers[self.selectedRowIndex];
    self.printer = [self.scannedTagsTVC.nfcPrinterList objectForKey:self.selectedPrinterSN];
    self.tagElem = [self.printer allKeys];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Check if the "Status" button already enabled or not.
    if (self.navigationItem.rightBarButtonItem.enabled == YES) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES; // Re-enable the "Connect" button to highlight it
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Number of cell is based on the number of elements associated with the number of
    // elements of the dictionary for a printer serial number.
    return [[[self.scannedTagsTVC nfcPrinterList] objectForKey:self.selectedPrinterSN] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"reuseIdentifier";

    // Retrieve a cell with the given identifier from the table view.
    // The cell is defined in the main storyboard: its identifier is reuseIdentifier, and its selection style is set to None.

    TagDetailTableViewCell *cell = (TagDetailTableViewCell *) [tableView dequeueReusableCellWithIdentifier:identifier];

    // Configure the cell...
    cell.tagElemName.text = [self.tagElem[indexPath.row] stringByAppendingString:@":"];
    cell.tagElemValue.text = [self.printer objectForKey:self.tagElem[indexPath.row]];

    if ([cell.tagElemName.text isEqualToString:@"url:"]) {
        // Make the background color of the URL cell in lightgrey.
        [cell setBackgroundColor:[UIColor colorWithRed:217.0/255.0
                                                 green:217.0/255.0
                                                  blue:217.0/255.0 alpha:1.0]];
        cell.tagElemValue.textColor = [UIColor blueColor];
    } else {
        [cell setUserInteractionEnabled:NO];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TagDetailTableViewCell *cell = (TagDetailTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];

    // Pop up the full detail of the complete URL.
    if ([cell.tagElemName.text isEqualToString:@"url:"]) {
        [Util showAlert:cell.tagElemValue.text
              withTitle:@"Full URL" withStyle:UIAlertControllerStyleActionSheet
        withActionTitle:@"OK" inViewController:self];
    }
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    PrinterStatusViewController *printerStatusVC = (PrinterStatusViewController *)[segue destinationViewController];
    
    // Pass the printer serial number to the destination PrinterStatusViewController.
    printerStatusVC.printerSN  = self.selectedPrinterSN;
}

@end
