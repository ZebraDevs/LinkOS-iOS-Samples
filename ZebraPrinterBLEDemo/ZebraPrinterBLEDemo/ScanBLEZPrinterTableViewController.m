//
//  ScanBLEZPrinterTableViewController.m
//  ZebraPrinterBLEDemo
//
//  Created by Zebra ISV Team on 11/17/17.
//  Copyright © 2017 Zebra. All rights reserved.
//

#import "ScanBLEZPrinterTableViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ZPrinterLEService.h"
#import "ConnectBLEZPrinterViewController.h"

@interface ScanBLEZPrinterTableViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) NSArray               *bleDeviceNames;
@property (strong, nonatomic) NSMutableDictionary   *blePrinterList;
@property (strong, nonatomic) IBOutlet UIButton     *connect;
@property (strong, nonatomic) CBPeripheral          *selectedPrinter;
@property (strong, nonatomic) CBPeripheral          *connectedPeripheral;

@end

@implementation ScanBLEZPrinterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Start up the CBCentralManager
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Initialize bleDeviceNames
    _bleDeviceNames = [[NSArray alloc] init];

    // Initialize blePrinterList
    _blePrinterList = [[NSMutableDictionary alloc] init];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bleDeviceNames count];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    static NSString *identifier = @"DeviceCellIdentifier";
    
    // Retrieve a cell with the given identifier from the table view.
    // The cell is defined in the main storyboard: its identifier is MyIdentifier, and  its selection style is set to None.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Set up the cell.
    NSString *deviceName = self.bleDeviceNames[indexPath.row];
    cell.textLabel.text = deviceName;

    if ([[self.blePrinterList[deviceName] objectForKey:@"selected"] isEqual:@YES]) {
        // Add checkmark to and highlighted the selected cell
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    } else {
        // Clear checkmark to the unselected cell
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if ([[self.blePrinterList[cell.textLabel.text] objectForKey:@"selected"] isEqual:@YES]) {
        // Current cell is already selected, then clear the selection
        [self.blePrinterList[cell.textLabel.text] setObject:@NO forKey:@"selected"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; // Deselect.
        self.navigationItem.rightBarButtonItem.enabled = NO; // Disable "Connect"
        self.selectedPrinter = nil;
    } else {
        // Unselect the previously selected device in blePrinterList.
        for (NSString *key in self.blePrinterList.allKeys) {
            [self.blePrinterList[key] setObject:@NO forKey:@"selected"];
        }
        // Clear the checkmark in the previously selected cell.
        for (int row = 0; row < [tableView numberOfRowsInSection:0]; row++) {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:cellPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [self.blePrinterList[cell.textLabel.text] setObject:@YES forKey:@"selected"];
        self.selectedPrinter = [self.blePrinterList[cell.textLabel.text] objectForKey:@"peripheral"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.navigationItem.rightBarButtonItem.enabled = YES; // Enable "Connect"
    }
}


/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
 
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

     if ([[segue identifier] isEqualToString:@"Connect"]) {
         // Get reference to the destination view controller
         ConnectBLEZPrinterViewController *connVC = [segue destinationViewController];
         connVC.scanBLEZPrinterTVC = self;
         connVC.selectedPrinter = self.selectedPrinter;
     }
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder { 
    // Do nothing yet
}

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection { 
    // Do nothing yet
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    // Do nothing yet
}

- (CGSize)sizeForChildContentContainer:(nonnull id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize { 
    // Do nothing yet
    CGSize *cgSize = 0;
    return *cgSize;
}

- (void)systemLayoutFittingSizeDidChangeForChildContentContainer:(nonnull id<UIContentContainer>)container { 
    // Do nothing yet
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    // Do nothing yet
}

- (void)willTransitionToTraitCollection:(nonnull UITraitCollection *)newCollection withTransitionCoordinator:(nonnull id<UIViewControllerTransitionCoordinator>)coordinator { 
    // Do nothing yet
}

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator { 
    // Do nothing yet
}

- (void)setNeedsFocusUpdate {
    // Do nothing yet
}

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context { 
    // Do nothing yet
    return YES;
}

- (void)updateFocusIfNeeded { 
    // Do nothing yet
}

//////////////////////////////////////////
////////////////BLE Stuff/////////////////
//////////////////////////////////////////

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state != CBManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBManagerStatePoweredOn, so start scanning
    [self scan];
}

// Scan for BLE peripherals - Zebra printers doesn't broadcast services. So we cannot scan for CBUUID.
- (void)scan
{
    // Search for ALL BLE devices nearby by searching through the BLE advertisements.
    // Zebra printer broadcasts its printer names in the advertisement.
    [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
}


// This callback comes whenever a BLE printer is discovered. We check the RSSI
// to make sure it's close enough that we're interested in it.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    if (RSSI.integerValue > -15) {
        return;
    }
    //    if (RSSI.integerValue > 5) {
    //        return;
    //    }
    
    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    //    if (RSSI.integerValue < -35) {
    //        return;
    //    }
    if (RSSI.integerValue < -70) {
        return;
    }

    // Ok, it's in the range. Let's add the device name to bleDeviceNames array
    if (peripheral.name.length) {
        // Remove leading & trailing whitespace in peripheral.name
        NSString *peripheralName = [peripheral.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        // New device that is not in the blePrinterList yet.
        if (![self.blePrinterList objectForKey:peripheralName]) {
            NSMutableDictionary *deviceFound = [[NSMutableDictionary alloc] init];
            [deviceFound setValue:peripheral forKey:@"peripheral"];
            [deviceFound setValue:@NO forKey:@"selected"];
            
            // Add to blePrinterList
            [self.blePrinterList setObject:deviceFound forKey:peripheralName];
            
            // Get an arrary of printer names
            self.bleDeviceNames = [[self.blePrinterList allKeys] sortedArrayUsingSelector:@selector(compare:)];

            // Reload the view table to let the user to choose which device to connect.
            [self.tableView reloadData];
        }
    }
}


// If the connection fails for whatever reason, we need to deal with it.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cleanup];
}


// We've connected to the peripheral, now we need to discover the services and characteristics.
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    // Stop scanning
    [self.centralManager stopScan];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match the UUID of Zebra Printer Service and the UUID of Device Information Service
    [peripheral discoverServices:@[[CBUUID UUIDWithString:ZPRINTER_SERVICE_UUID], [CBUUID UUIDWithString:ZPRINTER_DIS_SERVICE]]];
}


// The Zebra Printer Service was discovered
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        [self cleanup];
        return;
    }
    
    // Discover the characteristics of Write-To-Printer and Read-From-Printer.
    // Loop through the newly filled peripheral.services array, just in case there's more than one service.
    for (CBService *service in peripheral.services) {
        
        // Discover the characteristics of read from and write to printer
        if ([service.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_SERVICE_UUID]]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID],
                                                  [CBUUID UUIDWithString:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]] forService:service];
        } else if ([service.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_SERVICE]]) {
            
            // Discover the characteristics of Device Information Service (DIS)
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_MODEL_NAME],
                                                  [CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER],
                                                  [CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION],
                                                  [CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION],
                                                  [CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION],
                                                  [CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]] forService:service];

        }
    }
}


// The characteristics of Zebra Printer Service was discovered. Then we want to subscribe to the characteristics.
// This lets the peripheral know we want the data it contains.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        [self cleanup];
        return;
    }
    
    // Again, we loop through the array, as there might be multiple characteristics in service.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID]]) {
            
            // WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID is a write-only characteristic
            
            // Notify that Write Characteristic has been discovered through the Notification Center
            [[NSNotificationCenter defaultCenter] postNotificationName:ZPRINTER_WRITE_NOTIFICATION object:self userInfo:@{@"Characteristic":characteristic}];
            
        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]]) {

            // Set up notification for value update on "From Printer Data" characteristic, i.e. READ_FROM_ZPRINTER_CHARACTERISTIC_UUID.
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];

        } else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_MODEL_NAME]] ||
                   [characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER]] ||
                   [characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION]] ||
                   [characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION]] ||
                   [characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION]] ||
                   [characteristic.UUID isEqual:[CBUUID UUIDWithString:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]]) {
            
            // These characteristics are read-only characteristics.
            // Read value for these DIS characteristics
            [self.selectedPrinter readValueForCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in or to send ZPL to printer.
}


// This callback retrieves the values of the characteristics when they are updated.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Send read notification
    if ([characteristic.UUID.UUIDString isEqual:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ZPRINTER_READ_NOTIFICATION object:self
                                                          userInfo:@{@"Value":characteristic.value}];
    }
    // Check the UUID of characteristic is equial to the UUID of DIS characteristics
    else if ([characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MODEL_NAME] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]) {
     
        // Send DIS notification
        [[NSNotificationCenter defaultCenter] postNotificationName:ZPRINTER_DIS_NOTIFICATION object:self
                                                          userInfo:@{@"Characteristic":characteristic.UUID.UUIDString,
                                                                     @"Value":characteristic.value}];
    }
    
}


// The peripheral letting us know whether our subscribe/unsubscribe happened or not
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Deal with errors
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
        return;
    }
    
    // Exit if it's not the TRANSFER_CHARACTERISTIC_UUID characteristic, as it's our only interest at this time.
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


// Once the disconnection happens, we need to clean up our local copy of the peripheral
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    self.selectedPrinter = nil;

    // We're disconnected, so start scanning again
    [self scan];
}


// Call this when things either go wrong, or we're done with the connection.
// This cancels any subscriptions if there are any, or straight disconnects if not.
// (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.selectedPrinter.state != CBPeripheralStateConnected) {
        return;
    }

    // See if we are subscribed to a characteristic on the peripheral
    if (self.selectedPrinter.services != nil) {
        for (CBService *service in self.selectedPrinter.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.selectedPrinter setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.selectedPrinter];
}

// CBPeripheral delegate for event of didWriteValueForCharacteristic
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
    }
}


@end
