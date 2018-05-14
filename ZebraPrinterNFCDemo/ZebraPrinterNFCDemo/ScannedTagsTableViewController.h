//
//  ScannedTagsTableViewController.h
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/19/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScannedTagsTableViewController : UITableViewController

@property (strong, nonatomic) NSArray               *nfcPrinterSerialNumbers;
@property (strong, nonatomic) NSMutableDictionary   *nfcPrinterList;

@end
