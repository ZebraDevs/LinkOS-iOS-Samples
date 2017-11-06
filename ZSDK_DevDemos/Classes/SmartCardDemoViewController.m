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

#import "SmartCardDemoViewController.h"
#import "TcpPrinterConnection.h"
#import "ZebraPrinterFactory.h"

@implementation SmartCardDemoViewController

@synthesize loadingSpinner;
@synthesize printerConnection;
@synthesize printer;
@synthesize responseTextView;
@synthesize ATRButton;
@synthesize DATAButton;
@synthesize ipAddress;
@synthesize port;
@synthesize ipDnsTextField;
@synthesize portTextField;

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
	self.title = @"Smart Card";
	[self setUserDefaults];
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

-(void)updateResponseFieldOnGuiThread:(NSString *)response {
	[self.responseTextView setText:response];
}

-(void)stopSpinner {
	[self.loadingSpinner stopAnimating];
}

-(NSString*) NSDataToHexString:(NSData*)data
{
    NSInteger hexStringLength = [data length] * 2;
    NSMutableString* stringBuffer = [NSMutableString stringWithCapacity:hexStringLength];
    const unsigned char* dataBuffer = [data bytes];
    for (NSInteger i = 0; i < [data length]; i++)
    {
        [stringBuffer appendFormat:@"%02X", dataBuffer[i]];
    }
    return stringBuffer;
}

-(void)doSmartCardATR {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([self connectToPrinter] == YES) {
		id<SmartCardReader, NSObject> reader = [self.printer getSmartCardReader];
		
		NSError *smartCardError = nil;
		NSData *rawResponse = [reader getATR:&smartCardError];
        NSString *response = [self NSDataToHexString:rawResponse];
		if (smartCardError != nil) {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[smartCardError localizedDescription] waitUntilDone:YES];
		} else {
			[self performSelectorOnMainThread:@selector(updateResponseFieldOnGuiThread:) withObject:response waitUntilDone:YES];
		}
	}
	
	[self.printerConnection close];
	[self performSelectorOnMainThread:@selector(stopSpinner) withObject:nil waitUntilDone:YES];
	[pool release];
}

-(void)doSmartCardDATA {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if ([self connectToPrinter] == YES) {
		id<SmartCardReader, NSObject> reader = [self.printer getSmartCardReader];
		
		NSError *smartCardError = nil;
		NSData *rawResponse = [reader doCommand:@"8010000008" error:&smartCardError];
        NSString *response = [self NSDataToHexString:rawResponse];
		if (smartCardError != nil) {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[smartCardError localizedDescription] waitUntilDone:YES];
		} else {
			[self performSelectorOnMainThread:@selector(updateResponseFieldOnGuiThread:) withObject:response waitUntilDone:YES];
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

-(void)startSmartCardATROnThread {
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(doSmartCardATR) toTarget:self withObject:nil];
}

-(void)startSmartCardDATAOnThread {
	[self popupSpinner];
	[NSThread detachNewThreadSelector:@selector(doSmartCardDATA) toTarget:self withObject:nil];
}

-(IBAction)buttonPressed:(id)sender {
	[self.ipDnsTextField resignFirstResponder];
	[self.portTextField resignFirstResponder];
	[self saveUserDefaults:[self.ipDnsTextField text] portNumAsNsString:[self.portTextField text]];
	
	self.ipAddress = [self.ipDnsTextField text];
	self.port = [[self.portTextField text] intValue];
	
    UIButton *pressedButton = (UIButton*)sender;
    if (pressedButton  == self.ATRButton)
    {
        [self startSmartCardATROnThread];
    }
    else if (pressedButton == self.DATAButton)
    {
        [self startSmartCardDATAOnThread];
    }
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}

-(IBAction)backgroundTap : (id)sender {
	[self.ipDnsTextField resignFirstResponder];
	[self.portTextField	resignFirstResponder];
}

-(void)dealloc {
	[loadingSpinner release];
	[printerConnection close];
    [printerConnection release];
    [printer release];
    [responseTextView release];
    [ipAddress release];
    [ipDnsTextField release];
    [portTextField release];
	[super dealloc];
}

@end

