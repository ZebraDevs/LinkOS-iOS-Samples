/**********************************************
 * CONFIDENTIAL AND PROPRIETARY
 *
 * The source code and other information contained herein is the confidential and the exclusive property of
 * ZIH Corp. and is subject to the terms and conditions in your end user license agreement.
 * This source code, and any other information contained herein, shall not be copied, reproduced, published,
 * displayed or distributed, in whole or in part, in any medium, by any means, for any purpose except as
 * expressly permitted under such license agreement.
 *
 * Copyright ZIH Corp. 2013
 *
 * ALL RIGHTS RESERVED
 ***********************************************/

#import "LineModeViewController.h"
#import "ZebraPrinterConnection.h"
#import "TcpPrinterConnection.h"
#import "MfiBtPrinterConnection.h"
#import "SGD.h"


@implementation LineModeViewController


- (void)viewDidLoad {
	self.title = @"Line Mode";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
	self.performingDemo = NO;
	[self.view addSubview:self.connectivityViewController.view];
    [super viewDidLoad];
}

-(void) viewWillDisappear:(BOOL)animated{
	if (self.performingDemo) {
		[NSThread sleepForTimeInterval:5];
	}
}

- (IBAction)pageModeButtonPressed:(id)sender {
    [self.pageModeButton setEnabled:NO];
    [self.lineModeButton setEnabled:NO];
	[NSThread detachNewThreadSelector:@selector(performInterpretedLanguageDemo) toTarget:self withObject:nil];
}

- (IBAction)lineModeButtonPressed:(id)sender {
    [self.pageModeButton setEnabled:NO];
    [self.lineModeButton setEnabled:NO];
    [NSThread detachNewThreadSelector:@selector(performLineModeDemo) toTarget:self withObject:nil];
}

- (void) performInterpretedLanguageDemo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    self.performingDemo = YES;
    
    [self.connectivityViewController setStatus:@"Connecting..." withColor:[UIColor yellowColor]];
    id<ZebraPrinterConnection, NSObject> connection = nil;
    
    if(self.connectivityViewController.isBluetoothSelected) {
        connection = [[[MfiBtPrinterConnection alloc] initWithSerialNumber:self.connectivityViewController.bluetoothPrinterLabel.text] autorelease];
    } else {
        NSString *ipAddress = [self.connectivityViewController.ipDnsTextField text];
        NSString *portAsString = [self.connectivityViewController.portTextField text];
        int port = [portAsString intValue];
        connection = [[[TcpPrinterConnection alloc] initWithAddress:ipAddress andWithPort:port] autorelease];
    }
    
    BOOL didOpen = [connection open];
    if(didOpen == YES) {
        [self.connectivityViewController setStatus:@"Connected..." withColor:[UIColor greenColor]];
        [self.connectivityViewController setStatus:@"Sending Data" withColor:[UIColor cyanColor]];
        NSError *error = nil;

        /*
         Page Mode Demo :
            If your printer supports ZPL, (most  Zebra printers) you can set the printer's language to ZPL and use all the features of the SDK
            Some printers with ZPL support come shipped with "Line Print" mode enabled by default. Running this code will ensure that the printer language changes to ZPL for full SDK support.
         
            When the printer is in ZPL mode, you can no longer simply send lines followed by a '\r' to print, that functionality is reserved for line_print mode.
            If you wish to use line_print mode, set the printer's device.languages command to "line_print"
            There is also a helper method in the SGD class to wrap up the SGD pieces of the command.
         */

        [SGD SET:@"device.languages" withValue:@"zpl" andWithPrinterConnection:connection error:&error];
        
        NSString *testLabel = @"^XA^FO17,16^GB379,371,8^FS^FT65,255^A0N,135,134^FDTEST^FS^XZ";
        NSData *data = [NSData dataWithBytes:[testLabel UTF8String] length:[testLabel length]];
        [connection write:data error:&error];
        
        if (error != nil) {
            [self.connectivityViewController setStatus:@"Test Label Sent" withColor:[UIColor greenColor]];
        } else {
            [self.connectivityViewController setStatus:@"Test Label Failed to Print" withColor:[UIColor redColor]];
        }
    } else {
        [self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
    }
    
    [self.connectivityViewController setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
    
    [connection close];
    self.performingDemo = NO;
	
	[self.connectivityViewController setStatus:@"Not Connected" withColor:[UIColor redColor]];
	
    [self.pageModeButton setEnabled:YES];
    [self.lineModeButton setEnabled:YES];

	[pool release];
}

- (void) performLineModeDemo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    self.performingDemo = YES;

    [self.connectivityViewController setStatus:@"Connecting..." withColor:[UIColor yellowColor]];
    id<ZebraPrinterConnection, NSObject> connection = nil;
    
    if(self.connectivityViewController.isBluetoothSelected) {
        connection = [[[MfiBtPrinterConnection alloc] initWithSerialNumber:self.connectivityViewController.bluetoothPrinterLabel.text] autorelease];
    } else {
        NSString *ipAddress = [self.connectivityViewController.ipDnsTextField text];
        NSString *portAsString = [self.connectivityViewController.portTextField text];
        int port = [portAsString intValue];
        connection = [[[TcpPrinterConnection alloc] initWithAddress:ipAddress andWithPort:port] autorelease];
    }
    
    BOOL didOpen = [connection open];
    if(didOpen == YES) {
        [self.connectivityViewController setStatus:@"Connected..." withColor:[UIColor greenColor]];
        [self.connectivityViewController setStatus:@"Sending Data" withColor:[UIColor cyanColor]];
        /*
         Line Mode Demo :
            If your printer supports line mode, (most mobile Zebra printers) you can print lines just by writing to the connection followed by a '\r'.
            When the printer is in line_print mode, none of the other parts of the SDK will operate, since the SDK needs to send ZPL or CPCL in many cases.
            In order to set your printer to line mode, you need to send the following line down:
                ! U1 setvar "device.languages" "line_print"\r\n.
                There is also a helper method in the SGD class to wrap up the SGD pieces of the command.
         */
        NSError *error = nil;

        [SGD SET:@"device.languages" withValue:@"line_print" andWithPrinterConnection:connection error:&error];
        
        NSString *lineModeString = @"first line!\rsecond line!\rthird line!\r\r\r\r\r\r\r\r";
        
        NSInteger bytesSent = [connection write:[lineModeString dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        
        if (bytesSent == lineModeString.length && error == nil) {
            [self.connectivityViewController setStatus:@"Test Label Sent" withColor:[UIColor greenColor]];
        } else {
            [self.connectivityViewController setStatus:@"Test Label Failed to Print" withColor:[UIColor redColor]];
        }
    } else {
        [self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
    }
    
    [self.connectivityViewController setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
    
    [connection close];
    self.performingDemo = NO;
	
	[self.connectivityViewController setStatus:@"Not Connected" withColor:[UIColor redColor]];
	
    [self.pageModeButton setEnabled:YES];
    [self.lineModeButton setEnabled:YES];
	[pool release];
}

-(void)dealloc {
	[_connectivityViewController release];
    [_pageModeButton release];
    [_lineModeButton release];
	[super dealloc];
}

@end
