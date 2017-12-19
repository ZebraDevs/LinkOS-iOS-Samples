//
//  ScanBLEZPrinterTableViewController.h
//  ZebraPrinterBLEDemo
//
//  Created by Zebra ISV Team on 11/17/17.
//  Copyright © 2017 Zebra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ScanBLEZPrinterTableViewController : UITableViewController

@property (strong, nonatomic) CBCentralManager  *centralManager;

@end
