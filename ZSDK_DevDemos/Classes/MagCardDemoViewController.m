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

#import "MagCardDemoViewController.h"
#import "TcpPrinterConnection.h"
#import "ZebraPrinterFactory.h"

@implementation MagCardDemoViewController

@synthesize loadingSpinner;
@synthesize printerConnection;
@synthesize printer;
@synthesize ipDnsTextField;
@synthesize portTextField;
@synthesize port;
@synthesize ipAddress;
@synthesize readButton;
@synthesize t1TextField;
@synthesize t2TextField;
@synthesize t3TextField;

- (void) setUserDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self.ipDnsTextField setText:[defaults objectForKey:@"ipDnsName"]];
	[self.portTextField setText:[defaults objectForKey:@"portNum"]];
}


- (void) saveUserDefaults: (NSString *) ipDnsName portNumAsNsString: (NSString *) portNumAsNsString  {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:ipDnsName forKey:@"ipDnsName"];
	[defaults setObject:portNumAsNsString forKey:@"portNum"];
}

- (void)viewDidLoad {
	self.title = @"MagCard";
	[self setUserDefaults];
    [super viewDidLoad];
}


-(void)showErrorDialog :(NSString*)errorMessage {
    [self.readButton setEnabled:YES];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (BOOL) connectToPrinter {
	self.printerConnection = [[[TcpPrinterConnection alloc]initWithAddress:self.ipAddress andWithPort:self.port] autorelease];
	
	BOOL openedOk = NO;
	self.printer = nil;	
	
	if( ![self.printerConnection isConnected] ) {
		openedOk = [self.printerConnection open];
	}
	if (openedOk == YES) {
		NSError *connectionError = nil;
		
		self.printer = [ZebraPrinterFactory getInstance:self.printerConnection error:&connectionError];
		if (self.printer == nil) {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[connectionError localizedDescription] waitUntilDone:YES];
			return NO;
		}
	} else {
		[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:@"Connection Failed" waitUntilDone:YES];
		return NO;
	}	
	
	return YES;
}


-(void)updateTrackFieldsOnGuiThread:(NSArray *)tracks {
    [self.readButton setEnabled:YES];
	[self.t1TextField setText:(NSString*)[tracks objectAtIndex:0]];
	[self.t2TextField setText:(NSString*)[tracks objectAtIndex:1]];
	[self.t3TextField setText:(NSString*)[tracks objectAtIndex:2]];
}


-(void)stopSpinner {
	[self.loadingSpinner stopAnimating];
}

-(IBAction)doReadMagCard {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([self connectToPrinter] == YES) {
		id<MagCardReader,NSObject> reader = [self.printer getMagCardReader];
		
		NSError *magCardError = nil;
		NSArray *tracks = [reader read:10000 error:&magCardError];
		if (magCardError != nil) {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[magCardError localizedDescription] waitUntilDone:YES];
		} else {
			[self performSelectorOnMainThread:@selector(updateTrackFieldsOnGuiThread:) withObject:tracks waitUntilDone:YES];
		}
	}
	
	[self.printerConnection close];
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

-(void)startMagCardReadOnThread {
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(doReadMagCard) toTarget:self withObject:nil];
}

-(IBAction)buttonPressed:(id)sender {
	[self.ipDnsTextField resignFirstResponder];
	[self.portTextField resignFirstResponder];
	[self saveUserDefaults:[self.ipDnsTextField text] portNumAsNsString:[self.portTextField text]];
	
	self.ipAddress = [self.ipDnsTextField text];
	self.port = [[self.portTextField text] intValue];
    [self.readButton setEnabled:NO];
	
	[self startMagCardReadOnThread];
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}

-(IBAction)backgroundTap : (id)sender {
	[self.ipDnsTextField resignFirstResponder];
	[self.portTextField	resignFirstResponder];
}

-(void)dealloc {
	[printerConnection close];
	[printerConnection release];
	[readButton release];
	[t1TextField release];
	[t2TextField release];
	[t3TextField release];
	[loadingSpinner release];
    [printer release];
	[super dealloc];
}

@end

