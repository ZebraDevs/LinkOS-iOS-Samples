## 1. Introduction
In iOS 11, Apple introduced the [Core NFC Framework](https://developer.apple.com/documentation/corenfc?language=objc), which enables apps to detect Near Field Communication (NFC) tags. This is great news for developers writing iOS apps to work with Zebra mobile printers, because all Zebra mobile printers are NFC enabled. This makes it easy for apps to obtain the printer's Serial Number to pair with Bluetooth. This ZebraPrinterNFCDemo demonstrates how to read the NFC tags on Zebra mobile printers and how to pair with Bluetooth Classic or connect Bluetooth Low Energy, without going through the settings on the iOS device.
 
## 2. NFC Tag on Zebra Mobile Printers
Every Zebra mobile printer is equipped with a passive NFC tag. The tag is located on the right side of the printer and marked by an icon.  The NFC tag is encoded with the following information in a URL format, as an example shown below.
 
Full URL: http://www.zebra.com/apps/r/nfc?mE=000000000000&mW=&mB=cc78ab3ebae0&c=ZQ320-A0E02T0-00&s=XXZFJ170700336&v=0
 
|Keys |Values           |          Explanation             |
|----:|:----------------|:---------------------------------|
|host |www.zebra.com    |                                  |
|path |/apps/r/nfc      |                                  |
|mE   |000000000000     |Ethernet MAC Address              |
|mW   |                 |WiFi MAC Address                  |
|mB   |cc78ab3ebae0     |Bluetooth MAC Address             |
|c    |ZQ320-A0E02T0-00 |Printer Configurator (15 digits)  |
|s    |XXZFJ170700336   |Printer Serial Number (14 digits) |
|v    |0                |Zebra "URL Record" Version        |
 
On iOS, the Serial Number is used when making a connection to a printer over the Bluetooth.
 
## 3. Code Overview
### 3.1. Scanning NFC Tag
In this demo, we let `ScannedTagsTableViewController` class adapt the `NFCNDEFReaderSessionDelegate` interface and provide implementation to `readerSession:didDetectNDEFs:` and `readerSession:didInvalidateWithError:` delegate functions.
 
The `NFCNDEFReaderSession` session starts through the action below, triggered by pressing the Scan button.
```Objective-C
// Scan an NFC tag after scanBtn is pressed
- (IBAction)scanNFCTag:(id)sender {
    NFCNDEFReaderSession *session = [[NFCNDEFReaderSession alloc] initWithDelegate:self queue:dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT) invalidateAfterFirstRead:YES];
    [session beginSession];
}
``` 
When the NFC tag scan completes, the `readerSession:didDetectNDEFs:` delegate function is invoked. We let this function parse the information encoded in the NFC tag to make sure it is a correct tag for Zebra printer. Then the parsed information is stored in a dictionary in key-value pairs, which is then added to an array list to display in `ScannedTagsTableViewController`.
```Objective-C
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
```
### 3.2. Connecting to Bluetooth Classic
Connecting to the Bluetooth Classic is handled by `PrinterStatusViewController` class, by using the `showBluetoothAccessoryPickerWithNameFilter:completion:`. The Bluetooth picker filters out other Bluetooth devices by using the Serial Number that was obtained from scanning the NFC tag of the printer.
```Objective-C
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
```
### 3.3. Connecting to Bluetooth Low Energy
Connecting to Bluetooth Low Energy is handled by `ZebraBTLEConnection` class with `ZebraBTLEConnectionDelegate` defined in ` ZebraBTLEConnection.h`. The `ZebraBTLEConnection` class encapsulates the peripheral details of Zebra Bluetooth Low Energy and wraps the CoreBluetooth API.
```Objective-C
// Defines protocols that must be implemented
@protocol ZebraBTLEConnectionDelegate <NSObject>
 
@required
- (void) didFindSpecifiedPrinter:(NSString *) printerSerialNumber;
- (void) didDiscoverZPrinterWriteCharacteristic: (CBCharacteristic *) writeCharacteristic;
- (void) didReceiveUpdateOnZPrinterReadCharacteristic: (NSData *) data;
- (void) didReceiveUpdateOnZprinterDISCharacteristic: (NSDictionary *) disNameValue;
@end
 
@interface ZebraBTLEConnection : NSObject
 
// Define a singleton
+ (instancetype) getInstance: (id <ZebraBTLEConnectionDelegate>) delegate;
 
- (void) scan:(NSString *) printerSN;
- (BOOL) open;
- (BOOL) isOpen;
- (void) write:(NSString *) zpl;
- (void) close;
 
@end
```
Same as connecting to Bluetooth Classic, we use ` PrinterStatusViewController` to initiate the connection to Bluetooth Low Energy. Therefore, ` PrinterStatusViewController` adapts ` ZebraBTLEConnectionDelegate` and implements the delegate functions defined above.
### 3.4. Printer Status Parser
In this demo, the `ZebraPrinterStatus` class is provided for parsing the printer status string that is returned through `~HS` ZPL command. The `Check Printer Status with ~HS` button triggers the `~HS` command being sent to the printer over Bluetooth Low Energy. The returned status string is received via `didReceiveUpdateOnZPrinterReadCharacteristic:` delegate function. The `Print Test Label` button sends a “Hello World” barcode ZPL to the printer over Bluetooth Low Energy. Refer to the source code of `ZebraPrinterStatus` class for details on how the status string is parsed.
```Objective-C
// Get the current status of the printer.
+ (ZebraPrinterStatus*) getCurrentStatus: (NSData*)data error:(NSError**) error;
```

## 4. Demo in Action
![Image of ZebraPrinterNFCDemo](https://github.com/Zebra/LinkOS-iOS-Samples/blob/ZebraPrinterNFCDemo/ZebraPrinterNFCDemo/ZebraPrinterNFCDemo.gif)

## 5. References
This ZebraPrinterNFCDemo uses or refers to the following materials:
* [Print Touch - Printer NFC Details](https://developer.zebra.com/community/home/blog/2018/05/29/print-touch-printer-nfc-details), by Robin West, Zebra.
