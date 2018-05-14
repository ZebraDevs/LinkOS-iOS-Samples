//
//  BTLEConnectivity.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/30/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "ZebraBTLEConnection.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ZebraBTLEConnection () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, retain) NSString          *printerSN;
@property (strong, nonatomic) CBPeripheral      *printerPeripheral;
@property (strong, nonatomic) CBCharacteristic  *printerWriteCharacteristic;

@property (nonatomic) BOOL scanned;
@property (nonatomic) BOOL connectable;
@property (nonatomic) BOOL connected;

@property (strong, nonatomic) CBCentralManager  *centralManager;

@property (nonatomic, weak, nullable) id <ZebraBTLEConnectionDelegate> delegate;

@end

@implementation ZebraBTLEConnection

// Implementation of the singleton
static ZebraBTLEConnection *instance = nil;

+ (instancetype) getInstance: (id <ZebraBTLEConnectionDelegate>) delegate
{
    static ZebraBTLEConnection *instance;
    static dispatch_once_t once;

    dispatch_once(&once, ^
                  {
                      instance = [[[self class] alloc] init];
                  });

    instance.delegate = delegate; // Set the delegate

    return instance;
}

- (instancetype) init {
    if (self = [super init]) {
        // Start up the CBCentralManager
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        // Init the flags
        _connected = NO;
        _connectable = NO;
        _scanned = NO;
    }
    
    return self;
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    if (central.state != CBManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }

    // Scan for printerSN if it's not been scanned.
    if (!self.scanned) {
        // Set flag
        self.scanned = YES;
        
        // Search for ALL BLE devices nearby by searching through the BLE advertisements.
        // Zebra printer broadcasts its printer names in the advertisement.
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
}

// Scan for BLE peripherals - Zebra printers doesn't broadcast services. So we cannot scan for CBUUID.
- (void)scan:(NSString *)printerSN
{
    self.printerSN = printerSN; // Set the printer serial number

    if (self.centralManager.state != CBManagerStatePoweredOn) {
        // Not in CBManagerStatePoweredOn state yet.
        // Set flag to let the state change callback to start the scan
        self.scanned = NO;
        return;
    } else {
        // Search for ALL BLE devices nearby by searching through the BLE advertisements.
        // Zebra printer broadcasts its printer names in the advertisement.
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        self.scanned = YES;
    }
}

- (BOOL) isOpen {
    return self.connected;
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
        
        // Check if it's the desired printer.
        if ([peripheralName isEqualToString:self.printerSN]) {

            // Found the printer
            if ((BOOL)advertisementData[CBAdvertisementDataIsConnectable] == YES) {
                self.connectable = YES; // Note: BTLE on Zebra printers is always connectable
                self.printerPeripheral = peripheral;
                NSLog(@"%@ is connectable", peripheralName);
                
                // Stop scanning, as we have found the desired printer peripheral.
                [self.centralManager stopScan];
                
                // Invoke the callback to notify that the specified printer was found.
                if (self.delegate && [self.delegate respondsToSelector:@selector(didFindSpecifiedPrinter:)]) {
                    // Dispatch to the main queue
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate didFindSpecifiedPrinter:peripheralName];
                    });
                }
            } else {
                self.connectable = NO;
                NSLog(@"%@ is NOT connectable", peripheralName);
            }
        }
    }
}


// If the connection fails for whatever reason, we need to deal with it.
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self cleanup];
}


// Connect to printer peripheral after scanned
- (BOOL) open {
    if (self.printerPeripheral != nil && [self.printerPeripheral.name isEqualToString:self.printerSN]) {
        [self.centralManager connectPeripheral:self.printerPeripheral options:nil];
        return true;
    } else {
        NSLog(@"%@ has not been found yet", self.printerSN);
        return false;
    }
}

// Write ZPL to the connected printer
- (void) write:(NSString *) zpl {
    // Convert the ZPL to NSData to send to the printer
    const char *bytes = [zpl UTF8String];
    size_t length = [zpl length];
    NSData *payload = [NSData dataWithBytes:bytes length:length];
    NSLog(@"Writing payload: %@ length of %zu", payload, length);
    [self.printerPeripheral writeValue:payload forCharacteristic:self.printerWriteCharacteristic type:CBCharacteristicWriteWithResponse];
}

// Close connection
- (void) close {
    if (self.connected) {
        [self cleanup];
    }
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
        if ([service.UUID.UUIDString isEqual:ZPRINTER_SERVICE_UUID]) {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID],
                                                  [CBUUID UUIDWithString:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]] forService:service];
        } else if ([service.UUID.UUIDString isEqual:ZPRINTER_DIS_SERVICE]) {
            
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
        if ([characteristic.UUID.UUIDString isEqual:WRITE_TO_ZPRINTER_CHARACTERISTIC_UUID]) {
            
            // Mark as connected
            self.connected = YES;
            
            // Discovered the "write to" characteristic, which is a write-only characteristic.
            self.printerWriteCharacteristic = characteristic;

            // Invoke the callback to notify that the write characteristic was discovered.
            if (self.delegate && [self.delegate respondsToSelector:@selector(didDiscoverZPrinterWriteCharacteristic:)]) {
                // Dispatch to the main queue
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate didDiscoverZPrinterWriteCharacteristic:characteristic];
                });
            }

        } else if ([characteristic.UUID.UUIDString isEqual:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]) {
            
            // Set up notification for value update on "From Printer Data" characteristic, i.e. READ_FROM_ZPRINTER_CHARACTERISTIC_UUID.
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
        } else if ([characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MODEL_NAME] ||
                   [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER] ||
                   [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION] ||
                   [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION] ||
                   [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION] ||
                   [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]) {
            
            // These characteristics are read-only characteristics.
            // Read value for these DIS characteristics
            [self.printerPeripheral readValueForCharacteristic:characteristic];
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
        
        // Invoke the callback on the delegate to pass the received data
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveUpdateOnZPrinterReadCharacteristic:)]) {
            // Dispatch to the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceiveUpdateOnZPrinterReadCharacteristic:characteristic.value];
            });
        }
    }
    // Check the UUID of characteristic is equial to the UUID of DIS characteristics
    else if ([characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MODEL_NAME] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SERIAL_NUMBER] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_FIRMWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_HARDWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_SOFTWARE_REVISION] ||
             [characteristic.UUID.UUIDString isEqual:ZPRINTER_DIS_CHARAC_MANUFACTURER_NAME]) {
        
        // Compose DIS name value pair
        NSDictionary *disNameValue = @{characteristic.UUID.UUIDString:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]};
        if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveUpdateOnZprinterDISCharacteristic:)]) {
            // Dispatch to the main queue
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didReceiveUpdateOnZprinterDISCharacteristic:disNameValue];
            });
        }
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
    
    // Exit if it's not the READ_FROM_ZPRINTER_CHARACTERISTIC_UUID characteristic, as it's our only interest at this time.
    if (![characteristic.UUID.UUIDString isEqual:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]) {
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
//        [self.centralManager cancelPeripheralConnection:peripheral];
        
        // Call cleanup
        [self cleanup];
    }
}


// Once the disconnection happens, we need to clean up our local copy of the peripheral
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    // Clean up the printer peripheral and write characteristic
    self.printerPeripheral = nil;
    self.printerWriteCharacteristic = nil;

    // Reset the flags
    self.connected = NO;
    self.connectable = NO;
    self.scanned = NO;
}


// Call this when things either go wrong, or we're done with the connection.
// This cancels any subscriptions if there are any, or straight disconnects if not.
// (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.printerPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.printerPeripheral.services != nil) {
        for (CBService *service in self.printerPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID.UUIDString isEqual:READ_FROM_ZPRINTER_CHARACTERISTIC_UUID]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.printerPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.printerPeripheral];
    
    // Reset the flags
    self.connected = NO;
    self.connectable = NO;
    self.scanned = NO;
    
    self.printerPeripheral = nil;
    self.printerWriteCharacteristic = nil;
}

// CBPeripheral delegate for event of didWriteValueForCharacteristic
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error writing characteristic value: %@", [error localizedDescription]);
    }
}


@end
