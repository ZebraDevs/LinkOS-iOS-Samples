/**********************************************
 * CONFIDENTIAL AND PROPRIETARY
 *
 * The source code and other information contained herein is the confidential and the exclusive property of
 * ZIH Corp. and is subject to the terms and conditions in your end user license agreement.
 * This source code, and any other information contained herein, shall not be copied, reproduced, published,
 * displayed or distributed, in whole or in part, in any medium, by any means, for any purpose except as
 * expressly permitted under such license agreement.
 *
 * Copyright ZIH Corp. 2012
 *
 * ALL RIGHTS RESERVED
 ***********************************************/

#import "DemoListViewController.h"
#import "ConnectivityDemoController.h"
#import "DiscoveryViewController.h"
#import "ImagePrintDemoViewController.h"
#import "StatusViewController.h"
#import "StoredFormatViewController.h"
#import "ListFormatsDemoViewController.h"
#import "SignatureCaptureDemoViewController.h"
#import "MagCardDemoViewController.h"
#import "SmartCardDemoViewController.h"
#import "SendFileDemoViewController.h"
#import "LineModeViewController.h"
#import "CreateReceiptViewController.h"
#import "XmlReceiptPrintingViewController.h"

@interface DemoListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (strong,nonatomic) UITableView *table;
@property (strong,nonatomic) NSArray     *content;

@end

@implementation DemoListViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self cofigureTableview];
    self.content = @[@"Connectivity", @"Discovery", @"Image Print", @"List Formats", @"Mag Card", @"Printer Status", @"Smart Card", @"Signature Capture", @"Send File", @"Stored Format", @"Revert to Line Mode (iMZ)", @"Receipt Printing", @"XML Printing"];

}


-(void)cofigureTableview
{
    CGRect bounds = self.view.bounds;
    bounds.size.height -= (self.navigationController.navigationBar.frame.size.height + 20);
    self.table = [[UITableView alloc] initWithFrame:bounds style:UITableViewStylePlain];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [self.table dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
    }
    cell.textLabel.text =  [_content objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger row = [indexPath row];
    UIViewController *anotherViewController = nil;
    switch (row) {
        case 0:
            anotherViewController = [[ConnectivityDemoController alloc] initWithNibName:@"ConnectivityView" bundle:nil];
            
            break;
        case 1:
            anotherViewController = [[DiscoveryViewController alloc] initWithNibName:@"DiscoveryView" bundle:nil];
            break;
        case 2:
            anotherViewController = [[ImagePrintDemoViewController alloc] initWithNibName:@"ImagePrintView" bundle:nil];
            break;
        case 3:
            anotherViewController = [[ListFormatsDemoViewController alloc] initWithNibName:@"ListFormatsDemoView" bundle:nil];
            break;
        case 4:
            anotherViewController = [[MagCardDemoViewController alloc] initWithNibName:@"MagCardView" bundle:nil];
            break;
        case 5:
            anotherViewController = [[StatusViewController alloc] initWithNibName:@"StatusView" bundle:nil];
            break;
        case 6:
            anotherViewController = [[SmartCardDemoViewController alloc] initWithNibName:@"SmartCardView" bundle:nil];
            break;
        case 7:
            anotherViewController = [[SignatureCaptureDemoViewController alloc] initWithNibName:@"SignatureView" bundle:nil];
            break;
        case 8:
            anotherViewController = [[SendFileDemoViewController alloc] initWithNibName:@"SendFileView" bundle:nil];
            break;
        case 9:
            anotherViewController = [[StoredFormatViewController alloc] initWithNibName:@"StoredFormatView" bundle:nil];
            break;
        case 10:
            anotherViewController = [[LineModeViewController alloc] initWithNibName:@"LineModeView" bundle:nil];
            break;
        case 11:
            anotherViewController = [[CreateReceiptViewController alloc] initWithNibName:@"CreateReceiptView" bundle:nil];
            break;
        case 12:
            anotherViewController = [[XmlReceiptPrintingViewController alloc] initWithNibName:@"XmlReceiptPrintingView" bundle:nil];
            break;
        default:
            break;
    }
    if (anotherViewController != nil) {
        [self.navigationController pushViewController:anotherViewController animated:YES];
        [anotherViewController release];
    }
}


@end

