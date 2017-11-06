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

#import "StoredFormatViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"
#import "StoredPrinterFormatsViewController.h"
#import "TcpPrinterConnection.h"
#import "ZebraPrinterFactory.h"
#import "FileUtil.h"
#import "MfiBtPrinterConnection.h"

@implementation StoredFormatViewController


- (void)viewDidLoad {
	self.title = @"Stored Format";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
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
	[self.loadingSpinner stopAnimating];
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void) getListOfFormatsFromPrinter {		
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
        self.printer = [ZebraPrinterFactory getInstance:connection error:&error];
		if (self.printer != nil) {
			PrinterLanguage lang = [self.printer getPrinterControlLanguage];
			
			NSArray *extensions = (PRINTER_LANGUAGE_ZPL == lang) ? [NSArray arrayWithObject:@"ZPL"] : [NSArray arrayWithObjects:@"FMT",@"LBL",nil];
			id<FileUtil,NSObject> fileUtil = [self.printer getFileUtil];
            
            [self.connectivityViewController setStatus:@"Retrieving files..." withColor:[UIColor blueColor]];

			self.fileNames = [fileUtil retrieveFileNamesWithExtensions:extensions error:&error];

		} else {
            [self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
		}
	} else {
		[self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
	}
    
}

-(IBAction)backgroundTap : (id)sender {
	[self.connectivityViewController.ipDnsTextField resignFirstResponder];
	[self.connectivityViewController.portTextField	resignFirstResponder];
}


-(void)pushFilesViewController {
	[self.loadingSpinner stopAnimating];

	StoredPrinterFormatsViewController *controller = [[StoredPrinterFormatsViewController alloc]initWithFormats:self.fileNames andWithPrinter:self.printer];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
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

-(IBAction)buttonPressed:(id)sender {
	[self popupSpinner];
    [self.connectivityViewController.segmentedControl setEnabled:NO];
    [self.getFormatsButton setEnabled:NO];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.fileNames = nil;
        [self getListOfFormatsFromPrinter];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connectivityViewController.segmentedControl setEnabled:YES];
            [self.getFormatsButton setEnabled:YES];

            if(self.fileNames != nil) {
                [self pushFilesViewController];
            } else {
                [self showErrorDialog:@"Error retrieving files"];
            }
        });        
    });
}

-(void)dealloc {
	[_printerConnection close];
	[_printerConnection release];
	[_loadingSpinner release];
    [_printer release];
	[_getFormatsButton release];
	[_fileNames release];
	[super dealloc];
}

@end
