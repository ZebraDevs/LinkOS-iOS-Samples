//
//  PrinterStatusViewController.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/28/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "PrinterStatusViewController.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "ZebraBTLEConnection.h"
#import "ZebraPrinterStatus.h"
#import "Util.h"

@interface PrinterStatusViewController () <ZebraBTLEConnectionDelegate>

// BT LE related outlets
@property (strong, nonatomic) IBOutlet UILabel *lePrinterModel;
@property (strong, nonatomic) IBOutlet UILabel *lePrinterSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *lePrinterHWRev;
@property (strong, nonatomic) IBOutlet UILabel *lePrinterManufacturer;
@property (strong, nonatomic) IBOutlet UILabel *lePrinterFWRev;
@property (strong, nonatomic) IBOutlet UILabel *lePrinterSWRev;
@property (strong, nonatomic) IBOutlet UILabel  *btLEConnStatus;
@property (strong, nonatomic) IBOutlet UIButton *scanBTLEButton;
@property (strong, nonatomic) IBOutlet UIButton *connectBTLEButton;
@property (strong, nonatomic) IBOutlet UIButton *disconnectBTLEButton;
@property (strong, nonatomic) IBOutlet UIButton *printBTLETestLabelButton;
@property (strong, nonatomic) IBOutlet UIButton *checkBTLEPrinterStatusButton;

// BT LE connection
@property (strong, nonatomic) ZebraBTLEConnection *connection;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong, nonatomic) NSMutableData    *data;


// BT Classic related outlets
@property (strong, nonatomic) IBOutlet UILabel *btPrinterName;
@property (strong, nonatomic) IBOutlet UILabel *btPrinterModelNumber;
@property (strong, nonatomic) IBOutlet UILabel *btPrinterProtocolString;
@property (strong, nonatomic) IBOutlet UILabel *btPrinterSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel *btPrinterManufacturer;

@property (strong, nonatomic) IBOutlet UILabel *btClassicConnStatus;

// BT picker flag
@property (nonatomic) BOOL pickerComplete;

@end

@implementation PrinterStatusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"The printer SN = %@", self.printerSN);
    
    // Reset BT picker flag
    [self setPickerComplete:NO];

    self.navigationItem.title = self.printerSN; // Change the title to printer serial number.
    
    // Disable connect button and disconnect buton
    self.connectBTLEButton.enabled = NO;
    self.connectBTLEButton.backgroundColor = [UIColor grayColor];
    self.disconnectBTLEButton.enabled = NO;
    self.disconnectBTLEButton.backgroundColor = [UIColor grayColor];
    self.printBTLETestLabelButton.enabled = NO;
    self.printBTLETestLabelButton.backgroundColor = [UIColor grayColor];
    self.checkBTLEPrinterStatusButton.enabled = NO;
    self.checkBTLEPrinterStatusButton.backgroundColor = [UIColor grayColor];

    // Update the section label title
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByAppendingString:self.printerSN];
    self.btClassicConnStatus.text = [self.btClassicConnStatus.text stringByAppendingString:self.printerSN];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillDisappear :(BOOL)animated {
    NSLog(@"The view is going to disappear");
    
    // Call BTLE close
    if (self.connection != nil && [self.connection isOpen] == YES) {
        // Close BTLE
        [self.connection close];
    }
}

#pragma mark - BT Classic

// Called when "Connect with Bluetooth Classic" button is pressed.
- (IBAction)connectBTClassic:(id)sender {
    [self checkBTPrinterStatus:self.printerSN];
}

#pragma mark - BTLE

// Called when "Scan BTLE" button is pressed
- (IBAction)scanBTLE:(id)sender {
    // Disable the button
    self.scanBTLEButton.enabled = NO;
    self.scanBTLEButton.backgroundColor = [UIColor lightGrayColor];
    [self.scanBTLEButton setTitle:@"Scanning ..." forState:UIControlStateNormal];
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByReplacingOccurrencesOfString:self.printerSN withString:@"Scanning ..."];
    
    self.connection = [ZebraBTLEConnection getInstance:self];
    [self.connection scan:self.printerSN];
}

// Called when "Connect BTLE" button is pressed.
- (IBAction)connectBTLE:(id)sender {
    // Disable the connect button
    self.connectBTLEButton.enabled = NO;
    self.connectBTLEButton.backgroundColor = [UIColor lightGrayColor];
    [self.connectBTLEButton setTitle:@"Connecting ..." forState:UIControlStateNormal];
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByReplacingOccurrencesOfString:@"Found" withString:@"Connecting ..."];

    [self.connection open]; // Open the connection to the printer
}

// Called when Disconnect button is pressed
- (IBAction)disconnectBTLE:(id)sender {
    // Disable Disconnected button
    self.disconnectBTLEButton.enabled = NO;
    self.disconnectBTLEButton.backgroundColor = [UIColor grayColor];
    
    // Disable "Print Test Label" button
    self.printBTLETestLabelButton.enabled = NO;
    self.printBTLETestLabelButton.backgroundColor = [UIColor grayColor];

    // Disable "Check Printer Status with ~HS" button
    self.checkBTLEPrinterStatusButton.enabled = NO;
    self.checkBTLEPrinterStatusButton.backgroundColor = [UIColor grayColor];

    // Disable Connected button
    self.connectBTLEButton.enabled = NO;
    self.connectBTLEButton.backgroundColor = [UIColor grayColor];
    [self.connectBTLEButton setTitle:@"Connect BTLE" forState:UIControlStateNormal];

    // Enable "Scan BTLE" button
    self.scanBTLEButton.enabled = YES;
    self.scanBTLEButton.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]; // Default blue color
    [self.scanBTLEButton setTitle:@"Scan BTLE" forState:UIControlStateNormal];
    
    // Clear the received DIS values
    self.lePrinterModel.text = nil;
    self.lePrinterSerialNumber.text = nil;
    self.lePrinterFWRev.text = nil;
    self.lePrinterHWRev.text = nil;
    self.lePrinterSWRev.text = nil;
    self.lePrinterManufacturer.text = nil;
    
    // Update the title of section label
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByReplacingOccurrencesOfString:@"Connected" withString:self.printerSN];
    
    [self.connection close];
}

// Print a test label over BTLE
- (IBAction)printBTLETestLabel:(id)sender {
    if ([self.connection isOpen]) {
        // Get the ZPL from the ZPL text view and append newline and carriage return to the end just incase
        NSString *zpl = @"~hi^XA^FO20,20^BY3^B3N,N,150,Y,N^FDHello World!^FS^XZ\r\n";
        [self.connection write:zpl];
    } else {
        [Util showAlert:[self.printerSN stringByAppendingString:@" BTLE connection is lost. Close and restart the connection."]
              withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
        withActionTitle:@"OK" inViewController:self];
    }
}

// Check the printer status over BTLE
- (IBAction)checkBTLEPrinterStatus:(id)sender {
    if ([self.connection isOpen]) {
        // Get the ZPL from the ZPL text view and append newline and carriage return to the end just incase
        NSString *zpl = @"~HS";
        [self.connection write:zpl];
    } else {
        [Util showAlert:[self.printerSN stringByAppendingString:@" BTLE connection is lost. Close and restart the connection."]
              withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
        withActionTitle:@"OK" inViewController:self];
    }
}

// This callback is called when WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID is discovered
- (void)discoverWriteCharacteristic:(NSNotification *) notification {
    
    // Set the writeCharacteristic
    self.writeCharacteristic = [notification userInfo][@"Characteristic"];
    
    // Update the title to connected
    self.title = @"Connected";
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Bluetooth Classic
// Check the Bluetooth printer status, i.e. connected/paired?
- (void)checkBTPrinterStatus:(NSString*) printerSN {
    
    // Check if it's already paired before
    [[EAAccessoryManager sharedAccessoryManager] registerForLocalNotifications];
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager] connectedAccessories];
    for (EAAccessory *acc in accessories) {
        if ([acc.name isEqualToString:printerSN]) {
            NSLog(@"Accessor %@ is already connected", acc.serialNumber);
            
            // The printer is already connected
            if (!_pickerComplete) {
                // Don't show this alert if the picker complete successfully.
                [Util showAlert:[printerSN stringByAppendingString:@" is already connected"]
                      withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
                withActionTitle:@"OK" inViewController:self];
            }

            [self setPickerComplete:NO]; // Reset the picker flag

            // Populate the attributes on UIView
            self.btPrinterName.text           = acc.name;
            self.btPrinterModelNumber.text    = acc.modelNumber;
            self.btPrinterManufacturer.text   = acc.manufacturer;
            self.btPrinterSerialNumber.text   = acc.serialNumber;
            self.btPrinterProtocolString.text = acc.protocolStrings[0];

            return;
        }
    }
    
    // Looks like the printer is not connected. Pop up the Bluetooth picker.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", printerSN];
    [[EAAccessoryManager sharedAccessoryManager] showBluetoothAccessoryPickerWithNameFilter:predicate
                                                                                 completion:^(NSError *error) {
        if (error) {
            NSLog(@"error :%@", error);
            self.pickerComplete = NO; // Reset the picker flag.

            // Show an alert
            [Util showAlert:([@"Make sure the BT Classic of "
                              stringByAppendingString:[printerSN stringByAppendingString:@" is enabled and not already connected to another device."]])
                  withTitle:@"Alert" withStyle:UIAlertControllerStyleAlert
            withActionTitle:@"OK" inViewController:self];
        }
        else{
            NSLog(@"We made it! Well done!!!");
            self.pickerComplete = YES; // Set the picker flag.
            [self checkBTPrinterStatus:self.printerSN]; // Call to update the labels.
        }
    }];
}


#pragma mark - ZebraBTLEConnectionDelegate

// Implementation is required by ZebraBTLEConnectionDelegate protocol
- (void) didFindSpecifiedPrinter:(NSString *) printerSerialNumber {
    // We found the printer. Change the title and disable the button.
    self.scanBTLEButton.enabled = NO;
    [self.scanBTLEButton setTitle:@"Found" forState:UIControlStateNormal];
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByReplacingOccurrencesOfString:@"Scanning ..." withString:@"Found"];
    
    // Enable connect button
    self.connectBTLEButton.enabled = YES;
    self.connectBTLEButton.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]; // Default blue color
}

// Implementation is required by ZebraBTLEConnectionDelegate protocol
- (void)didDiscoverZPrinterWriteCharacteristic:(CBCharacteristic *)writeCharacteristic {

    // Disable the connect button and change the title
    self.connectBTLEButton.enabled = NO;
    [self.connectBTLEButton setTitle:@"Connected" forState:UIControlStateNormal];
    self.btLEConnStatus.text = [self.btLEConnStatus.text stringByReplacingOccurrencesOfString:@"Connecting ..." withString:@"Connected"];

    // Enable the print test label button and disconnect button.
    self.printBTLETestLabelButton.enabled = YES;
    self.printBTLETestLabelButton.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]; // Default blue color

    // Enable the check printer status with ~HS button.
    self.checkBTLEPrinterStatusButton.enabled = YES;
    self.checkBTLEPrinterStatusButton.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]; // Default blue color

    self.disconnectBTLEButton.enabled = YES;
    self.disconnectBTLEButton.backgroundColor = [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1]; // Default blue color
}


// Implementation is required by ZebraBTLEConnection protocol
- (void)didReceiveUpdateOnZPrinterReadCharacteristic:(NSData *) data {

    NSError *error = nil;
    
    ZebraPrinterStatus *status = [ZebraPrinterStatus getCurrentStatus:data error:&error];
    
    if (error) {
        NSLog(@"Received non-status msg: %@", [error localizedDescription]);
        return;
    }
    
    [Util showAlert:[NSString stringWithFormat:@"isReadyToPrint: %@\r\nisHeadOpen: %@\r\nisHeadCold: %@\r\nisHeadTooHot: %@\r\nisPaperOut: %@\r\nisRibbonOut: %@\r\nisReceiveBufferFull: %@\r\nisPaused: %@\r\nisPartialFormatInProgress: %@\r\nlabelLengthInDots: %ld\r\nnumberOfFormatsInReceiveBuffer: %ld\r\nlabelsRemainingInBatch: %ld\r\nzplPrintMode: %@",
                     ([status isReadyToPrint]? @"Yes" : @"No"), ([status isHeadOpen]? @"Yes" : @"No"),
                     ([status isHeadCold]? @"Yes" : @"No"), ([status isHeadTooHot]? @"Yes" : @"No"),
                     ([status isPaperOut]? @"Yes" : @"No"), ([status isRibbonOut]? @"Yes" : @"No"),
                     ([status isReceiveBufferFull]? @"Yes" : @"No"), ([status isPaused]? @"Yes" : @"No"),
                     ([status isPartialFormatInProgress]? @"Yes" : @"No"), (long)[status labelLengthInDots],
                     (long)[status numberOfFormatsInReceiveBuffer], (long)[status labelsRemainingInBatch],
                     [ZebraPrinterStatus getPrintModeLocalizedDescriptino:[status printMode]]]
          withTitle:@"Printer Status" withStyle:UIAlertControllerStyleAlert
    withActionTitle:@"OK" inViewController:self];
}


// Implementation is required by ZebraBTLEConnection protocol
- (void)didReceiveUpdateOnZprinterDISCharacteristic:(NSDictionary *) disNameValue {
    // Update the DIS fields on UI.
    for (NSString *key in disNameValue) {
        // Set the corresponding fields
        if ([key isEqual:ZPRINTER_DIS_CHARAC_MODEL_NAME]) {
            self.lePrinterModel.text = [disNameValue valueForKey:key];
        } else if ([key isEqual:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER]) {
            self.lePrinterSerialNumber.text = [disNameValue valueForKey:key];
        } else if ([key isEqual:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION]) {
            self.lePrinterFWRev.text = [disNameValue valueForKey:key];
        } else if ([key isEqual:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION]) {
            self.lePrinterHWRev.text = [disNameValue valueForKey:key];
        } else if ([key isEqual:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION]) {
            self.lePrinterSWRev.text = [disNameValue valueForKey:key];
        } else if ([key isEqual:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]) {
            self.lePrinterManufacturer.text = [disNameValue valueForKey:key];
        }
    }
}

@end
