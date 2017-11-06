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

#import "BluetoothPrintersViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "ZSDKDeveloperDemosAppDelegate.h"

@interface BluetoothPrintersViewController ()

@end

@implementation BluetoothPrintersViewController

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
    EAAccessoryManager *manager = [EAAccessoryManager sharedAccessoryManager];

    self.bluetoothPrinters = [[[NSMutableArray alloc] initWithArray:manager.connectedAccessories] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bluetoothPrinters.count;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"If you do not see your printer here, you need to make sure it is configured in your iOS settings.   Go to Settings > Bluetooth and pair with your printer.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    EAAccessory *accessory = [self.bluetoothPrinters objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", accessory.name, accessory.serialNumber];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EAAccessory *accessory = [self.bluetoothPrinters objectAtIndex:indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bluetoothPrinterSelected" object:accessory.serialNumber];

    ZSDKDeveloperDemosAppDelegate *del = (ZSDKDeveloperDemosAppDelegate *)[UIApplication sharedApplication].delegate;
    [del.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc {
    [_bluetoothPrinters release];
    [super dealloc];
}
@end
