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

#import "SendFileDemoViewController.h"
#import "TcpPrinterConnection.h"
#import "ZebraPrinterFactory.h"
#import "MfiBtPrinterConnection.h"

@implementation SendFileDemoViewController

-(void) popupSpinner{
	self.loadingSpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	[self.view addSubview:self.loadingSpinner];
	self.loadingSpinner.center = self.view.center;
	self.loadingSpinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | 
										   UIViewAutoresizingFlexibleTopMargin | 
										   UIViewAutoresizingFlexibleRightMargin | 
										   UIViewAutoresizingFlexibleLeftMargin;
	[self.loadingSpinner startAnimating];
}

- (void)viewDidLoad {
	self.title = @"Send File";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
	[self.view addSubview:self.connectivityViewController.view];
    [super viewDidLoad];
}

-(void)showErrorDialog :(NSString*)errorMessage {
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)showSuccessDialog {
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"File sent to printer" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


-(void) sendFileToPrinter {
    
	[self.sendFileButton setEnabled:NO];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
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
		
		[self.connectivityViewController setStatus:@"Determining Printer Language..." withColor:[UIColor yellowColor]];
		
		NSError *error = nil;
		id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
		
		if(printer != nil) {
			id<FileUtil, NSObject> fileUtil = [printer getFileUtil];
			
			NSString *fileName = ([printer getPrinterControlLanguage] == PRINTER_LANGUAGE_ZPL) ? @"test_zpl.zpl" : @"test_cpcl.lbl";
			NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fileName];
			
			if ([fileUtil sendFileContents:filePath error:&error] == NO) {
				[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
			} else {
				[self performSelectorOnMainThread:@selector(showSuccessDialog) withObject:nil waitUntilDone:YES];
			}
		} else {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
		}
	} else {
		[self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
	}
	
	[self.connectivityViewController setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
	
	[connection close];
	
	[self.connectivityViewController setStatus:@"Not Connected" withColor:[UIColor redColor]];
	
	[self.sendFileButton setEnabled:YES];
	[pool release];
}

-(IBAction)buttonPressed:(id)sender {
	[self.connectivityViewController.ipDnsTextField resignFirstResponder];
	[self.connectivityViewController.portTextField resignFirstResponder];
    
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(sendFileToPrinter) toTarget:self withObject:nil];
}


-(IBAction)backgroundTap : (id)sender {
	[self.connectivityViewController.ipDnsTextField resignFirstResponder];
	[self.connectivityViewController.portTextField resignFirstResponder];
}

-(void)dealloc {
	[_loadingSpinner release];
    [_sendFileButton release];
	[super dealloc];
}

@end

