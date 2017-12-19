//
//  ConnectBLEZPrinterViewController.h
//  ZebraPrinterBLEDemo
//
//  Created by Zebra ISV Team on 11/26/17.
//  Copyright © 2017 Zebra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScanBLEZPrinterTableViewController.h"

@interface ConnectBLEZPrinterViewController : UIViewController <UITextViewDelegate>

@property(strong, nonatomic) CBPeripheral *selectedPrinter;
@property (strong, nonatomic) ScanBLEZPrinterTableViewController *scanBLEZPrinterTVC;

@end
