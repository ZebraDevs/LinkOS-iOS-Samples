//
//  ScannedTagsTableViewController.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/19/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "ScannedTagsTableViewController.h"
#import <CoreNFC/CoreNFC.h>
#import "TagDetailTableViewController.h"
#import "Util.h"

@interface ScannedTagsTableViewController () <NFCNDEFReaderSessionDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *clearBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *scanBtn;

@end

@implementation ScannedTagsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize nfcPrinterSerialNumbers
    self.nfcPrinterSerialNumbers = [NSArray array];

    // Initialize nfcPrinterList
    self.nfcPrinterList = [NSMutableDictionary dictionary];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Scan a NFC tag after scanBtn is pressed
- (IBAction)scanNFCTag:(id)sender {
    NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT) invalidateAfterFirstRead:YES];
    [session beginSession];
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nfcPrinterSerialNumbers count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    static NSString *identifier = @"reuseIdentifier";
    
    // Retrieve a cell with the given identifier from the table view.
    // The cell is defined in the main storyboard: its identifier is reuseIdentifier, and its selection style is set to None.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Set up the cell.
    NSString *serialNumber = self.nfcPrinterSerialNumbers[indexPath.row];
    cell.textLabel.text = serialNumber;
    
    return cell;
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

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
    TagDetailTableViewController *tagDetailTVC = (TagDetailTableViewController *)[segue destinationViewController];

    // Pass the object reference and the row index to the destination tableViewController.
    tagDetailTVC.scannedTagsTVC   = self;
    tagDetailTVC.selectedRowIndex = self.tableView.indexPathForSelectedRow.row;

 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }

// NFC NDEF Stuff
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didDetectNDEFs:(nonnull NSArray<NFCNDEFMessage *> *)messages {
    for (NFCNDEFMessage *message in messages) {
        for (NFCNDEFPayload *payload in message.records) {
            
            // Parse the URL
            // Check msg type. Return if it's not 'U'.
            uint8_t type;
            [payload.type getBytes:&type length:1];
            if (type != 'U') {
                // Unknow Zebra tag. Popup an alart.
                [Util showAlert:@"This is not a Zebra printer."
                      withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
                withActionTitle:@"OK" inViewController:self];
                
                return;
            }
            
            // Check if it's '0x01', for 'http://wwww.' prefix.
            [payload.payload getBytes:&type length:1];
            if (type != 0x01) {
                [Util showAlert:@"This is not a Zebra printer."
                      withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
                withActionTitle:@"OK" inViewController:self];

                return;
            }
            
            // Prepend 'http://www.', by replacing the first byte of '0x01'.
            NSRange range = NSMakeRange(1, [payload.payload length] - 1);
            NSData *tmpPayload = [payload.payload subdataWithRange:range];
            NSString *url = [[NSString alloc] initWithData:(NSData *)tmpPayload encoding:NSUTF8StringEncoding];
            url = [@"http://www." stringByAppendingString:url];

            // Parse the URL
            NSURLComponents *urlComp = [NSURLComponents componentsWithString:url];
            NSArray *queryItems = [urlComp queryItems];

            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            for (NSURLQueryItem *item in queryItems)
            {
                [dict setObject:[item value] forKey:[item name]];
            }
            
            NSArray<NSString*> *allKeys = [dict allKeys];
            if (![urlComp.host isEqualToString:@"www.zebra.com"] || ![urlComp.path isEqualToString:@"/apps/r/nfc"] ||
                ![allKeys containsObject:@"mE"] || ![allKeys containsObject:@"mW"] ||
                ![allKeys containsObject:@"mB"] || ![allKeys containsObject:@"c"] ||
                ![allKeys containsObject:@"s"]  || ![allKeys containsObject:@"v"] ){

                // If any condition above fails, show an alert.
                [Util showAlert:@"This is not a Zebra printer."
                      withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
                withActionTitle:@"OK" inViewController:self];

                return;
            }
            
            // Add the newly scanned tag to nfcPrinterSerialNumbers & nfcPrinterList
            // New device that is not in the blePrinterList yet.
            if (![self.nfcPrinterList objectForKey:[dict objectForKey:@"s"]]) {
                NSMutableDictionary *printer = [NSMutableDictionary dictionary];
                [printer setValue:url forKey:@"url"];
                [printer setValue:urlComp.host forKey:@"host"];
                [printer setValue:urlComp.path forKey:@"path"];
                [printer setValue:[dict objectForKey:@"mE"] forKey:@"mE"];
                [printer setValue:[dict objectForKey:@"mW"] forKey:@"mW"];
                [printer setValue:[dict objectForKey:@"mB"] forKey:@"mB"];
                [printer setValue:[dict objectForKey:@"c"] forKey:@"c"];
                [printer setValue:[dict objectForKey:@"s"] forKey:@"s"];
                [printer setValue:[dict objectForKey:@"v"] forKey:@"v"];
                
                // Add to nfcPrinterList
                [self.nfcPrinterList setObject:printer forKey:[dict objectForKey:@"s"]];
                
                // Get an arrary of printer names
                self.nfcPrinterSerialNumbers = [[self.nfcPrinterList allKeys] sortedArrayUsingSelector:@selector(compare:)];
                
                // Reload the view table to let the user to choose which printer to connect.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    // Your UI update code here
                });
            }
            
            NSLog(@"Temp Payload data in string format:%@", url);
        }
    }
}

// We need to implement this function, otherwise Xcode complains about not conforming to protocol 'NFCNDEFReaderSessionDelegate'
- (void)readerSession:(nonnull NFCNDEFReaderSession *)session didInvalidateWithError:(nonnull NSError *)error {

}

//- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
//    <#code#>
//}
//
//- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection {
//    <#code#>
//}
//
//- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
////- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
////    <#code#>
////}
//
//- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container {
//    <#code#>
//}
//
//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator {
//    <#code#>
//}
//
//- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator {
//    <#code#>
//}
//
//- (void)setNeedsFocusUpdate {
//    <#code#>
//}
//
////- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context {
////    <#code#>
////}
//
//- (void)updateFocusIfNeeded {
//    <#code#>
//}

// Clear the scanned tags when Clear Btn is pressed
- (IBAction)clearScannedTags:(id)sender {
    // Clear all scanned tags
    self.nfcPrinterSerialNumbers = [NSArray array];
    self.nfcPrinterList = [NSMutableDictionary dictionary];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        // Your UI update code here
    });
}


@end
