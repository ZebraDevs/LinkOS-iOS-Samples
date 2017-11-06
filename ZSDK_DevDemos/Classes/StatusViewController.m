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

#import "StatusViewController.h"
#import "ZebraPrinterConnection.h"
#import	"TcpPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "PrinterStatus.h"
#import "PrinterStatusMessages.h"
#import "MfiBtPrinterConnection.h"

@implementation StatusViewController

+(BOOL) deviceOrientationIsLandscape {
	UIInterfaceOrientation actualDeviceOrientation = [UIApplication sharedApplication].statusBarOrientation;	
	return (actualDeviceOrientation == UIDeviceOrientationLandscapeLeft || actualDeviceOrientation == UIDeviceOrientationLandscapeRight);
}

-(void)viewDidLoad {
	self.title = @"Printer Status";
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
	[self.view addSubview:self.connectivityViewController.view];
    [super viewDidLoad];
    
}

- (void) viewWillAppear:(BOOL)animated {	
	[super viewWillAppear:(BOOL)animated];
	[self.printerStatusText setText:@""];
	self.printerStatusText.layer.borderWidth = 3;
	self.printerStatusText.layer.borderColor = [[UIColor grayColor] CGColor];
	self.printerStatusText.layer.cornerRadius = 8;
	if ([StatusViewController deviceOrientationIsLandscape]) {
		[self.printerStatusText setFrame:CGRectMake(109,180,280,70)];
		[self.printerStatusText flashScrollIndicators];
	} else {
		[self.printerStatusText setFrame:CGRectMake(20,200,280,180)];
	}
	
}

-(void)viewDidAppear:(BOOL)animated {
	[self.printerStatusText flashScrollIndicators];
	[super viewDidAppear:animated];
}

-(NSString*) getLanguageName :(PrinterLanguage)language {
	if(language == PRINTER_LANGUAGE_ZPL){
		return @"ZPL";
	} else {
		return @"CPCL";
	}
}

-(void)connectTo:(NSString*) ipDnsName andPortNum:(NSString*)portNumAsNsString {
	NSArray *connectionInfo = [NSArray arrayWithObjects:ipDnsName, portNumAsNsString, nil];
	[NSThread detachNewThreadSelector:@selector(performConnectionDemo:) toTarget:self withObject:connectionInfo];
}


- (IBAction)checkStatusButtonPressed:(id)sender {
    [NSThread detachNewThreadSelector:@selector(performStatusDemo) toTarget:self withObject:nil];
}

- (void) performStatusDemo {
	[self.checkStatusButton setEnabled:NO];
	
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
			
			[self.connectivityViewController setStatus:@"Retreiving Status" withColor:[UIColor cyanColor]];
			
			PrinterStatus *status = [printer getCurrentStatus:&error];
			if (status == nil) {
				[self.connectivityViewController setStatus:@"Error retreiving status" withColor:[UIColor redColor]];
			} else {
				NSMutableString *statusMessages = [NSMutableString stringWithFormat:@"Ready to Print: %@\r\n", (status.isReadyToPrint ? @"TRUE" : @"FALSE")];
				
				[statusMessages appendFormat:@"Labels in Batch: %ld\r\n", (long)status.labelsRemainingInBatch];
				[statusMessages appendFormat:@"Labels in Buffer: %ld\r\n\r\n", (long)status.numberOfFormatsInReceiveBuffer];
				
				PrinterStatusMessages *printerStatusMessages = [[[PrinterStatusMessages alloc] initWithPrinterStatus:status] autorelease];
				NSArray *printerStatusMessagesArray = [printerStatusMessages getStatusMessage]; 
													   
				for(int i = 0; i < [printerStatusMessagesArray count]; i++) {
					[statusMessages appendFormat:@"%@\r\n", [printerStatusMessagesArray objectAtIndex:i]];
				}
				
				[self updatePrinterStatusText:statusMessages];
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
	
	[self.checkStatusButton setEnabled:YES];
	[pool release];
}

- (IBAction)backgroundTap:(id)sender {
    [self.connectivityViewController.ipDnsTextField resignFirstResponder];
    [self.connectivityViewController.portTextField	resignFirstResponder];
}

-(void)updatePrinterStatusText: (NSString*)status {
	[self performSelectorOnMainThread:@selector(updatePrinterStatusTextOnGuiThread:) withObject:status waitUntilDone:NO];
	[NSThread sleepForTimeInterval:1];
}

-(void)updatePrinterStatusTextOnGuiThread: (NSString*)status {
	[self.printerStatusText setText:status];
	[self.printerStatusText flashScrollIndicators];
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}


- (void)dealloc {
    [_printerStatusText release];
    [_checkStatusButton release];
	[super dealloc];
}

@end
