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

#import "SignatureCaptureDemoViewController.h"
#import "TcpPrinterConnection.h"
#import "ZebraPrinterFactory.h"
#import "MfiBtPrinterConnection.h"

@implementation SignatureCaptureDemoViewController


- (void)viewDidLoad {
	self.title = @"Signature Capture";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
    [self.view addSubview:self.connectivityViewController.view];
    [super viewDidLoad];
}

-(void)showErrorDialog :(NSString*)errorMessage {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(NSString*) getLanguageName :(PrinterLanguage)language {
	if(language == PRINTER_LANGUAGE_ZPL){
		return @"ZPL";
	} else {
		return @"CPCL";
	}
}

-(void)stopSpinner {
	[self.loadingSpinner stopAnimating];
}

-(void)doPrintSignature {
    [self.printSignatureButton setEnabled:NO];
	
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
			PrinterLanguage language = [printer getPrinterControlLanguage];
			
			[self.connectivityViewController setStatus:[NSString stringWithFormat:@"Printer Language %@",[self getLanguageName:language]] withColor:[UIColor cyanColor]];
			
			[self.connectivityViewController setStatus:@"Printing Signature" withColor:[UIColor cyanColor]];
			
            NSError *sigCaptureError = nil;
            id<GraphicsUtil, NSObject> graphicsUtil = [printer getGraphicsUtil];
            CGImageRef sigImage = [self.signatureArea getImage];
            [graphicsUtil printImage:sigImage atX:0 atY:0 withWidth:self.signatureArea.frame.size.width withHeight:self.signatureArea.frame.size.height andIsInsideFormat:NO error:&sigCaptureError];
            if (sigCaptureError != nil) {
                [self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[sigCaptureError localizedDescription] waitUntilDone:YES];
            }
            
		} else {
			[self.connectivityViewController setStatus:@"Could not Detect Language" withColor:[UIColor redColor]];
		}
	} else {
		[self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
	}
	
	[self.connectivityViewController setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
	
	[connection close];
	
	[self.connectivityViewController setStatus:@"Not Connected" withColor:[UIColor redColor]];
	
	[self.printSignatureButton setEnabled:YES];
    [self performSelectorOnMainThread:@selector(stopSpinner) withObject:nil waitUntilDone:YES];

	[pool release];    
}

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

-(void)startPrintSignatureOnThread {
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(doPrintSignature) toTarget:self withObject:nil];
}

-(IBAction)buttonPressed:(id)sender {
	
    [self startPrintSignatureOnThread];
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}

-(void)dealloc {
	[_loadingSpinner release];
    [_signatureArea release];
    [_connectivityViewController release];
    [_printSignatureButton release];
	[super dealloc];
}

- (void)viewDidUnload {
    [self setPrintSignatureButton:nil];
    [super viewDidUnload];
}
@end

