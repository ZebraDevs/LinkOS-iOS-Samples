//
//  MyFirstZebraAppViewController.m
//  MyFirstZebraApp
//
#import "ViewController.h"
#import "ZebraPrinterConnection.h"
#import	"TcpPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "PrinterStatus.h"
#import "PrinterStatusMessages.h"


@implementation ViewController

/*
 // The designated initializer. Override to perform setup that is required before the view is loaded.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

@synthesize statusLabel;
@synthesize ipDnsTextField;
@synthesize portTextField;
@synthesize testButton;
@synthesize printerStatusText;


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


+(BOOL) deviceOrientationIsLandscape {
    UIDeviceOrientation actualDeviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    return (actualDeviceOrientation == UIDeviceOrientationLandscapeLeft || actualDeviceOrientation == UIDeviceOrientationLandscapeRight);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    
    [self.printerStatusText setText:@""];
    self.printerStatusText.layer.borderWidth = 3;
    self.printerStatusText.layer.borderColor = [[UIColor grayColor] CGColor];
    self.printerStatusText.layer.cornerRadius = 8;
    /*	if ([ConnectivityDemoViewController deviceOrientationIsLandscape]) {
     [self.printerStatusText setFrame:CGRectMake(109,180,280,70)];
     [self.printerStatusText flashScrollIndicators];
     } else {
     [self.printerStatusText setFrame:CGRectMake(20,185,280,202)];
     }*/
    [self setUserDefaults];
    
    //From ViewDidAppear
    self.title = @"Connectivity Demo";
    [self.printerStatusText flashScrollIndicators];
    //End from ViewDidAppear
    
    
    [super viewDidLoad];
}

-(NSString*) getLanguageName :(PrinterLanguage)language {
    if(language == PRINTER_LANGUAGE_ZPL){
        return @"ZPL";
    } else {
        return @"CPCL";
    }
}

-(void) setButtonState : (BOOL)state {
    [self performSelectorOnMainThread:@selector(setTestButtonStateSelector:) withObject:[NSNumber numberWithBool:state] waitUntilDone:NO];
}

- (void) setTestButtonStateSelector : (NSNumber*)state {
    [self.testButton setEnabled:[state boolValue]];
}

-(void)setStatus: (NSString*)status withColor :(UIColor*)color {
    NSArray *statusInfo = [NSArray arrayWithObjects:status, color, nil];
    [self performSelectorOnMainThread:@selector(changeStatusLabel:) withObject:statusInfo waitUntilDone:NO];
    [NSThread sleepForTimeInterval:1];
}

-(IBAction)buttonPressed:(id)sender {
    NSString *ipDnsName = [self.ipDnsTextField text];
    NSString *portNumAsNsString = [self.portTextField text];
    
    NSArray *connectionInfo = [NSArray arrayWithObjects:ipDnsName, portNumAsNsString, nil];
    [self saveUserDefaults: ipDnsName portNumAsNsString: portNumAsNsString];
    [NSThread detachNewThreadSelector:@selector(performConnectionDemo:) toTarget:self withObject:connectionInfo];
}

-(void)updatePrinterStatusText: (NSString*)status {
    [self performSelectorOnMainThread:@selector(updatePrinterStatusTextOnGuiThread:) withObject:status waitUntilDone:NO];
    [NSThread sleepForTimeInterval:1];
}

-(BOOL)printTestLabel:(PrinterLanguage) language onConnection:(id<ZebraPrinterConnection, NSObject>)connection withError:(NSError**)error {
    NSString *testLabel;
    if (language == PRINTER_LANGUAGE_ZPL) {
        testLabel = @"^XA^FO17,80^GB379,371,8^FS^FT65,255^A0N,135,134^FDTEST^FS^XZ";
        NSData *data = [NSData dataWithBytes:[testLabel UTF8String] length:[testLabel length]];
        [connection write:data error:error];
    } else if (language == PRINTER_LANGUAGE_CPCL) {
        testLabel = @"! 0 200 200 406 1\r\nON-FEED IGNORE\r\nBOX 20 20 380 380 8\r\nT 0 6 137 177 TEST\r\nPRINT\r\n";
        NSData *data = [NSData dataWithBytes:[testLabel UTF8String] length:[testLabel length]];
        [connection write:data error:error];
    }
    if(*error == nil){
        return YES;
    } else {
        return NO;
    }
}

- (void) performConnectionDemo : (NSArray*)connectionInfo {
    [self setButtonState:NO];
    NSString *ipDnsName = [connectionInfo objectAtIndex:0];
    NSString *portNumAsText = [connectionInfo objectAtIndex:1];
    NSInteger portNum = [portNumAsText intValue];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    [self setStatus:@"Connecting..." withColor:[UIColor yellowColor]];
    
    
    id<ZebraPrinterConnection, NSObject> connection = [[TcpPrinterConnection alloc] initWithAddress:ipDnsName andWithPort:portNum];
    
    BOOL didOpen = [connection open];
    if(didOpen == YES) {
        [self setStatus:@"Connected..." withColor:[UIColor greenColor]];
        
        [self setStatus:@"Determining Printer Language..." withColor:[UIColor yellowColor]];
        
        NSError *error = nil;
        id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
        
        if(printer != nil) {
            PrinterLanguage language = [printer getPrinterControlLanguage];
            [self setStatus:[NSString stringWithFormat:@"Printer Language %@",[self getLanguageName:language]] withColor:[UIColor cyanColor]];
            
            [self setStatus:@"Sending Data" withColor:[UIColor cyanColor]];
            
            BOOL sentOK = [self printTestLabel:language onConnection:connection withError:&error];
            if (sentOK == YES) {
                [self setStatus:@"Test Label Sent" withColor:[UIColor greenColor]];
            } else {
                [self setStatus:@"Test Label Failed to Print" withColor:[UIColor redColor]];
            }
        } else {
            [self setStatus:@"Could not Detect Language" withColor:[UIColor redColor]];
        }
    } else {
        [self setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
    }
    
    [self setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
    
    [connection close];
    [connection release];
    
    
    [self setStatus:@"Not Connected" withColor:[UIColor redColor]];
    
    [self setButtonState:YES];
    [pool release];
}

-(void)updatePrinterStatusTextOnGuiThread: (NSString*)status {
    [self.printerStatusText setText:status];
    [self.printerStatusText flashScrollIndicators];
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


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [statusLabel release];
    [ipDnsTextField release];
    [portTextField release];
    [testButton release];
    [printerStatusText release];
    
    [super dealloc];
}

@end
