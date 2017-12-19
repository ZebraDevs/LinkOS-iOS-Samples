//
//  ConnectBLEZPrinterViewController.m
//  ZebraPrinterBLEDemo
//
//  Created by Zebra ISV Team on 11/26/17.
//  Copyright © 2017 Zebra. All rights reserved.
//

#import "ConnectBLEZPrinterViewController.h"
#import "ZPrinterLEService.h"

@interface ConnectBLEZPrinterViewController ()
@property (strong, nonatomic) IBOutlet UITextView   *zplTextview;
@property (strong, nonatomic) IBOutlet UITextView   *statusTextview;
@property (strong, nonatomic) IBOutlet UIButton     *sendButton;
@property (strong, nonatomic) IBOutlet UIButton     *doneButton;
@property (strong, nonatomic) NSMutableData         *data;

@property (strong, nonatomic) CBCharacteristic      *writeCharacteristic;

// DIS Values
@property (strong, nonatomic) IBOutlet UILabel      *disName;
@property (strong, nonatomic) IBOutlet UILabel      *disSerialNumber;
@property (strong, nonatomic) IBOutlet UILabel      *disManufacturerName;
@property (strong, nonatomic) IBOutlet UILabel      *disFirmwareRevision;
@property (strong, nonatomic) IBOutlet UILabel      *disHardwareRevision;
@property (strong, nonatomic) IBOutlet UILabel      *disSoftwareRevision;

@end

@implementation ConnectBLEZPrinterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Disable the Send button & the Done button
    self.sendButton.enabled = NO;
    self.doneButton.enabled = NO;

    // Stop scanning
    [[self.scanBLEZPrinterTVC centralManager] stopScan];

    // Connect to the selected printer.
    [[self.scanBLEZPrinterTVC centralManager] connectPeripheral:_selectedPrinter options:nil];
    
    // Initialize the data
    self.data = [[NSMutableData alloc] init];

    // Initialize the text views with default ZPL
//    self.zplTextview.text = @"~hi^XA^FO50,50^ADN,36,20^FDHELLO WORLD!^FS^XZ";
    self.zplTextview.text = @"~hi^XA^FO20,20^BY3^B3N,N,150,Y,N^FDHello World!^FS^XZ";
    
    self.zplTextview.layer.borderWidth = 0.5f;
    self.zplTextview.delegate = self;
    self.zplTextview.textColor =[UIColor lightGrayColor];
    
    // Specify the foreground color for the title of the navigation bar.
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    
    // Set statusTextview border
    self.statusTextview.layer.borderWidth = 0.5f;
    
    // Register for notification on discovery of Write Characteristic
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(discoverWriteCharacteristic:)
                                                 name:ZPRINTER_WRITE_NOTIFICATION
                                               object:nil];

    // Register for notification on data received from Read Characteristic
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDataFromReadCharacteristic:)
                                                 name:ZPRINTER_READ_NOTIFICATION
                                               object:nil];

    //////////////////////////////////////////////////////////
    // Register for notification on DIS values received from DIS Characteristic
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedDataFromDISCharacteristic:)
                                                 name:ZPRINTER_DIS_NOTIFICATION
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// This callback is called when WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID is discovered
- (void)discoverWriteCharacteristic:(NSNotification *) notification {
    
    // Set the writeCharacteristic
    self.writeCharacteristic = [notification userInfo][@"Characteristic"];

    // Update the title to connected
    self.title = @"Connected";

    // Enable the send button
    self.sendButton.enabled = YES;
}

// This callback is called when data from READ_FROM_ZPRINTER_CHARACTERISTIC_UUID is received.
- (void)receivedDataFromReadCharacteristic:(NSNotification *) notification {
    
    // Extract the data from notification
    [self.data appendData:[notification userInfo][@"Value"]];

    // Display data in statusTextview
    [self.statusTextview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];

    // Scroll the textview to the bottom.
    NSRange bottom = NSMakeRange(self.statusTextview.text.length - 1, 1);
    [self.statusTextview scrollRangeToVisible:bottom];
}

// This callback is called when data from DIS is received.
- (void)receivedDataFromDISCharacteristic:(NSNotification *) notification {

    // Extract Characteristic UUID & text
    NSString *uuid = [notification userInfo][@"Characteristic"];
    NSData *value = [notification userInfo][@"Value"];
    NSString *text = [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];

    // Set the corresponding fields
    if ([uuid isEqual:ZPRINTER_DIS_CHARAC_MODEL_NAME]) {
        self.disName.text = text;
    } else if ([uuid isEqual:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER]) {
        self.disSerialNumber.text = text;
    } else if ([uuid isEqual:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION]) {
        self.disFirmwareRevision.text = text;
    } else if ([uuid isEqual:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION]) {
        self.disHardwareRevision.text = text;
    } else if ([uuid isEqual:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION]) {
        self.disSoftwareRevision.text = text;
    } else if ([uuid isEqual:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]) {
        self.disManufacturerName.text = text;
    }

}

- (IBAction)sendZPL2Printer:(id)sender {
    // Get the ZPL from the ZPL text view and append newline and carriage return to the end just incase
    NSString *zpl = [self.zplTextview.text stringByAppendingString:@"\r\n"];

    const char *bytes = [zpl UTF8String];
    size_t length = [zpl length];
    NSData *payload = [NSData dataWithBytes:bytes length:length];
    NSLog(@"Writing payload: %@ length of %zu", payload, length);
    [self.selectedPrinter writeValue:payload forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (IBAction)doneZPLEdit:(id)sender {
    // Disable the Done button
    self.doneButton.enabled = NO;

    // Enable the Sone button
    self.sendButton.enabled = YES;

    // Change the text color to light gray
    self.zplTextview.textColor =[UIColor lightGrayColor];

    // Dismiss the keyboard
    [self.zplTextview resignFirstResponder];
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    // Enable the Done button
    self.doneButton.enabled = YES;

    // Disable the Send button
    self.sendButton.enabled = NO;
    
    // Change the text color to black
    self.zplTextview.textColor =[UIColor blackColor];
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    // Enable the Done button
    self.doneButton.enabled = NO;
    
    // Disable the Send button
    self.sendButton.enabled = YES;
    
    // Change the text color to light gray
    self.zplTextview.textColor =[UIColor lightGrayColor];
}

@end
