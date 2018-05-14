//
//  BTLEConnectivity.h
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/30/18.
//  Copyright © 2018 Zebra. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Zebra printer UUID, defined on Link-OS® Environment Bluetooth® Low Energy
// AppNote (https://www.zebra.com/content/dam/zebra/software/en/application-notes/AppNote-BlueToothLE-v4.pdf)
#define ZPRINTER_SERVICE_UUID                   @"38EB4A80-C570-11E3-9507-0002A5D5C51B"
#define WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID   @"38EB4A82-C570-11E3-9507-0002A5D5C51B"
#define READ_FROM_ZPRINTER_CHARACTERISTIC_UUID  @"38EB4A81-C570-11E3-9507-0002A5D5C51B"

// Device Information Service (DIS) of Zebra printer
#define ZPRINTER_DIS_SERVICE                    @"180A"
#define ZPRINTER_DIS_CHARAC_MODEL_NAME          @"2A24"
#define ZPRINTER_DIS_CHARAC_SERIAL_NUMBER       @"2A25"
#define ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION   @"2A26"
#define ZPRINTER_DIS_CHARAC_HARDWARE_REVISION   @"2A27"
#define ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION   @"2A28"
#define ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME   @"2A29"

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
