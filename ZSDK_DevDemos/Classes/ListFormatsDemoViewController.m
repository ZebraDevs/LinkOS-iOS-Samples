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

#import "ListFormatsDemoViewController.h"
#import "ListFormatsViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"
#import "ZebraPrinterConnection.h"
#import "TcpPrinterConnection.h"
#import "MfiBtPrinterConnection.h"
#import "ZebraPrinterFactory.h"
#import "FileUtil.h"

@implementation ListFormatsDemoViewController

static NSString* kFILENAMESKEY = @"filename";
static NSString* kERRORKEY = @"error";

- (void)viewDidLoad {
	self.title = @"List Formats";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
    self.connectionInfo = [[[NSMutableDictionary alloc] init] autorelease];

    [self.view addSubview:self.connectivityViewController.view];
    [super viewDidLoad];
}

-(NSString*) getLanguageName :(PrinterLanguage)language {
	if(language == PRINTER_LANGUAGE_ZPL){
		return @"ZPL";
	} else {
		return @"CPCL";
	}
}

-(void)showErrorDialog :(NSString*)errorMessage {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (IBAction)listFormatsButtonPressed:(id)sender {
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(getListOfFormatsFromPrinter) toTarget:self withObject:nil];
}

- (void) getListOfFormatsFromPrinter {
    [self.listFormatsButton setEnabled:NO];

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	id<ZebraPrinterConnection, NSObject> connection = nil;
    
    if(self.connectivityViewController.isBluetoothSelected) {
        connection = [[[MfiBtPrinterConnection alloc] initWithSerialNumber:self.connectivityViewController.bluetoothPrinterLabel.text] autorelease];
    } else {
        NSString *ipAddress = [self.connectivityViewController.ipDnsTextField text];
        NSString *portAsString = [self.connectivityViewController.portTextField text];
        int port = [portAsString intValue];
        connection = [[[TcpPrinterConnection alloc] initWithAddress:ipAddress andWithPort:port] autorelease];
    }
    
	BOOL openedOk = NO;
	self.printer = nil;
	[self.connectivityViewController setStatus:@"Connecting..." withColor:[UIColor yellowColor]];

	if( ![connection isConnected] ) {
		openedOk = [connection open];
		[self.connectivityViewController setStatus:@"Connected..." withColor:[UIColor greenColor]];
	}
	if (openedOk == YES) {
		NSError *error = nil;
		
		self.printer = [ZebraPrinterFactory getInstance:connection error:&error];
		if (self.printer != nil) {
			[self.connectivityViewController setStatus:@"Determining Printer Language..." withColor:[UIColor yellowColor]];	
			PrinterLanguage lang = [self.printer getPrinterControlLanguage];
			
			[self.connectivityViewController setStatus:[NSString stringWithFormat:@"Printer Language %@", [self getLanguageName:lang]] withColor:[UIColor cyanColor]];

			[self.connectivityViewController setStatus:@"Connected" withColor:[UIColor greenColor]];

			NSArray *extensions = (PRINTER_LANGUAGE_ZPL == lang) ? [NSArray arrayWithObject:@"ZPL"] : [NSArray arrayWithObjects:@"FMT",@"LBL",nil];
			id<FileUtil,NSObject> fileUtil = [self.printer getFileUtil];
			NSArray *fileNames = [fileUtil retrieveFileNamesWithExtensions:extensions error:&error];

			[self.connectionInfo setObject:fileNames forKey:kFILENAMESKEY];
			
		} else {
			[self.connectivityViewController setStatus:@"Could not Detect Language" withColor:[UIColor redColor]];
			[self.connectionInfo setObject:[error localizedDescription] forKey:kERRORKEY];
		}
        [connection close];
	} else {
		[self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
		[self.connectionInfo setObject:@"Connection Failed" forKey:kERRORKEY];
	}
	
	[self performSelectorOnMainThread:@selector(threadFinished) withObject:nil waitUntilDone:YES];
	[pool release];
    [self.listFormatsButton setEnabled:YES];

}

-(void)threadFinished {
	[self.loadingSpinner stopAnimating];
	
	NSString *errorString = [self.connectionInfo objectForKey:kERRORKEY];
	if (errorString == nil) {
		NSArray *fileNames = [self.connectionInfo objectForKey:kFILENAMESKEY];
		ListFormatsViewController *controller = [[ListFormatsViewController alloc]initWithFormats:fileNames andPrinter:self.printer];
		[self.navigationController pushViewController:controller animated:YES];
		[controller release];
	} else {
		[self showErrorDialog:errorString];
	}
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


- (void)dealloc {
	[_connectivityViewController release];
	[_loadingSpinner release];
    [_printer release];
    [_connectionInfo release];
    [_listFormatsButton release];
    [super dealloc];
}


- (void)viewDidUnload {
    [self setListFormatsButton:nil];
    [super viewDidUnload];
}
@end
