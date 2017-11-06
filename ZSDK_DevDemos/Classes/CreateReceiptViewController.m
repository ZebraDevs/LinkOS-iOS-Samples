/**********************************************
 * CONFIDENTIAL AND PROPRIETARY
 *
 * The source code and other information contained herein is the confidential and the exclusive property of
 * ZIH Corp. and is subject to the terms and conditions in your end user license agreement.
 * This source code, and any other information contained herein, shall not be copied, reproduced, published,
 * displayed or distributed, in whole or in part, in any medium, by any means, for any purpose except as
 * expressly permitted under such license agreement.
 *
 * Copyright ZIH Corp. 2013
 *
 * ALL RIGHTS RESERVED
 ***********************************************/


#import "CreateReceiptViewController.h"
#import "ReceiptPrintingViewController.h"

@interface CreateReceiptViewController ()
@property(retain) NSArray *products;
@property(retain) NSArray *prices;
@property(retain) NSMutableArray *itemsToPrint;
@end

@implementation CreateReceiptViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.products = [NSArray arrayWithObjects:@"Sneakers (Size 7)", @"XL T-Shirt", @"Socks (3-pack)", @"Blender", @"DVD Movie", nil];
    self.prices = [NSArray arrayWithObjects:[NSNumber numberWithFloat:69.99], [NSNumber numberWithFloat:39.99], [NSNumber numberWithFloat:12.99], [NSNumber numberWithFloat:34.99], [NSNumber numberWithFloat:16.99], nil];
    
    NSDictionary *defaultItem = @{ @"Microwave Oven" : [NSNumber numberWithFloat:79.99]};
    self.itemsToPrint = [[[NSMutableArray alloc] initWithObjects:defaultItem, nil] autorelease];
    
    
    UIBarButtonItem *addLineButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed)] autorelease];
    
    self.navigationItem.rightBarButtonItem = addLineButton;
}

-(void)addButtonPressed {
    int randomNumber = rand() % self.products.count;
    
    NSDictionary *randomItem = @{ self.products[randomNumber] : self.prices[randomNumber]};
    [self.itemsToPrint insertObject:randomItem atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)] autorelease];

    UIButton *printButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [printButton setFrame:CGRectMake(0, 0, 100, 40)];
    [printButton setTitle:@"Print" forState:UIControlStateNormal];
    printButton.center = customView.center;
    [printButton addTarget:self action:@selector(printButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:printButton];
    
    return customView;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 60.0f;
}

-(void) printButtonPressed {
    
    ReceiptPrintingViewController *receiptPrintingViewController = [[ReceiptPrintingViewController alloc] initWithNibName:@"ReceiptPrintingView" bundle:nil];

    receiptPrintingViewController.itemsToPrint = self.itemsToPrint;
    [self.navigationController pushViewController:receiptPrintingViewController animated:YES];
    [receiptPrintingViewController release];
     
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.itemsToPrint.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *currentItem = self.itemsToPrint[indexPath.row];
    NSString *key = [currentItem allKeys][0];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"$%@", currentItem[key]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)dealloc {
    [_itemsToPrint release];
    [_products release];
    [_prices release];
    [super dealloc];
}


@end
