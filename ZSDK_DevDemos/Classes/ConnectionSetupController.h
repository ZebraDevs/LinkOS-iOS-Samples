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

#import <ExternalAccessory/ExternalAccessory.h>

@interface ConnectionSetupController : UIViewController

@property (nonatomic,retain) IBOutlet UILabel *statusLabel;
@property (nonatomic,retain) IBOutlet UITextField *ipDnsTextField;
@property (nonatomic,retain) IBOutlet UITextField *portTextField;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UIControl *networkView;
@property (retain, nonatomic) IBOutlet UIView *bluetoothView;
@property (retain, nonatomic) IBOutlet UIButton *bluetoothButton;
@property(nonatomic, assign)BOOL isBluetoothSelected;
@property (retain, nonatomic) IBOutlet UILabel *bluetoothPrinterLabel;

-(IBAction)textFieldDoneEditing : (id)sender;
-(IBAction)backgroundTap : (id)sender;
- (IBAction)segmentedControlChanged:(id)sender;
- (IBAction)chooseBluetoothButtonPressed:(id)sender;
-(void)setStatus: (NSString*)status withColor :(UIColor*)color;
@end
