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

#import "ConnectionSetupController.h"
#import "TcpPrinterConnection.h"
#import "MfiBtPrinterConnection.h"
#import "BluetoothPrintersViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"

@implementation ConnectionSetupController

-(id)init {
	self = [self initWithNibName:@"ConnectionSetupView" bundle:nil];
	[self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
	[self setUserDefaults];
    self.isBluetoothSelected = NO;
    self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 134);
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bluetoothPrinterSelected:) name:@"bluetoothPrinterSelected" object:nil];
	return self;
}

- (void) bluetoothPrinterSelected:(NSNotification *) notification
{
    NSString *btSerialNumber = notification.object;
    [self.bluetoothPrinterLabel setText:btSerialNumber];
}

- (void) setUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self.ipDnsTextField setText:[defaults objectForKey:@"ipDnsName"]];
	[self.portTextField setText:[defaults objectForKey:@"portNum"]];
    [self.bluetoothPrinterLabel setText:[defaults objectForKey:@"bluetooth"]];
}

- (void) saveUserDefaults: (NSString *) ipDnsName portNumAsNsString: (NSString *) portNumAsNsString andWithBluetoothSerialNum:(NSString*) aBluetoothSerialNumber {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:ipDnsName forKey:@"ipDnsName"];
	[defaults setObject:portNumAsNsString forKey:@"portNum"];
    [defaults setObject:aBluetoothSerialNumber forKey:@"bluetooth"];
}

-(void)setStatus: (NSString*)status withColor :(UIColor*)color {
	NSArray *statusInfo = [NSArray arrayWithObjects:status, color, nil];
	[self performSelectorOnMainThread:@selector(changeStatusLabel:) withObject:statusInfo waitUntilDone:NO];
	[NSThread sleepForTimeInterval:1];
}

-(void)changeStatusLabel: (NSArray*)statusInfo {
	NSString *statusText = [statusInfo objectAtIndex:0];
	UIColor *statusColor = [statusInfo objectAtIndex:1];
	
	NSString *tmpStatus = [NSString stringWithFormat:@"Status : %@", statusText];
	[self.statusLabel setText:tmpStatus];
	[self.statusLabel setBackgroundColor:statusColor];
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}

-(IBAction)backgroundTap : (id)sender {
	[self.ipDnsTextField resignFirstResponder];
	[self.portTextField	resignFirstResponder];
}

- (IBAction)segmentedControlChanged:(id)sender {
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.networkView setHidden:NO];
            [self.bluetoothView setHidden:YES];
            self.isBluetoothSelected = NO;
            break;
        case 1:
            [self enableBluetoothView];
            self.isBluetoothSelected = YES;
            break;
        default:
            break;
    }
}

-(void)enableBluetoothView {
    [self.networkView setHidden:YES];
    [self.bluetoothView setHidden:NO];
}

- (IBAction)chooseBluetoothButtonPressed:(id)sender {
    ZSDKDeveloperDemosAppDelegate *del = (ZSDKDeveloperDemosAppDelegate *)[UIApplication sharedApplication].delegate;
    
    BluetoothPrintersViewController *btViewController = [[BluetoothPrintersViewController alloc] initWithNibName:@"BluetoothPrintersView" bundle:nil];
    [del.navigationController pushViewController:btViewController animated:YES];
    [btViewController release];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self saveUserDefaults:self.ipDnsTextField.text portNumAsNsString:self.portTextField.text andWithBluetoothSerialNum:self.bluetoothPrinterLabel.text];
    [super viewWillDisappear:animated];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc {
	[_statusLabel release];
	[_ipDnsTextField release];
	[_portTextField release];
    [_segmentedControl release];
    [_networkView release];
    [_bluetoothView release];
    [_bluetoothButton release];
    [_bluetoothPrinterLabel release];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bluetoothPrinterSelected" object:nil];
	[super dealloc];
}

@end
