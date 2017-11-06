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

#import "XmlReceiptPrintingViewController.h"
#import "ZebraPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "TcpPrinterConnection.h"
#import "MfiBtPrinterConnection.h"

@interface XmlReceiptPrintingViewController ()

@end

@implementation XmlReceiptPrintingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
	self.title = @"XML Printing";
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

-(NSString*) getLanguageName :(PrinterLanguage)language {
	if(language == PRINTER_LANGUAGE_ZPL){
		return @"ZPL";
	} else {
		return @"CPCL";
	}
}

- (IBAction)printButtonPressed:(id)sender {
	[NSThread detachNewThreadSelector:@selector(performConnectionDemo) toTarget:self withObject:nil];
}

- (void) performConnectionDemo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    self.performingDemo = YES;
    [self.printButton setEnabled:NO];
    
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
            
            if(language == PRINTER_LANGUAGE_CPCL) {
                [self.connectivityViewController setStatus:@"This demo will not work for CPCL printers!" withColor:[UIColor redColor]];
            } else {
                [self.connectivityViewController setStatus:@"Storing ZPL labels on printer" withColor:[UIColor cyanColor]];
                [self storeZplLabels:printer];

                [self.connectivityViewController setStatus:@"Sending XML to Printer" withColor:[UIColor cyanColor]];
                [self sendXml:printer];
            }
            
        } else {
            [self.connectivityViewController setStatus:@"Could not Detect Language" withColor:[UIColor redColor]];
        }
    } else {
        [self.connectivityViewController setStatus:@"Could not connect to printer" withColor:[UIColor redColor]];
    }
    
    [self.connectivityViewController setStatus:@"Disconnecting..." withColor:[UIColor redColor]];
    
    [connection close];
    self.performingDemo = NO;
	
	[self.connectivityViewController setStatus:@"Not Connected" withColor:[UIColor redColor]];
	
    [self.printButton setEnabled:YES];
	[pool release];
}

-(void)storeZplLabels : (id<NSObject,ZebraPrinter>)printer {
    
    /*
     For XML printing to work, the label formats need to be saved onto the printer's memory so that the XML report can recall it for printing. 
     Storing files only needs to be done once, but for the sake of this demo, we are sending the ZPL formats to the printer every time.
     In this example, the formats are saved onto drive R (RAM) and the formats will be deleted on printer reboot.
     If you wish to persist the ZPL formats for use across reboots, store the formats on drive E.
     */
    NSError *error = nil;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *header = [NSString stringWithFormat:
        @"^XA^DFR:MYHEADER.ZPL^FS^POI^PW400^MNN^LL325^LH0,0" \
        
        @"^FO50,50" \
        @"^A0,N,70,70" \
        @"^FD Shipping^FS" \
        
        @"^FO50,130" \
        @"^A0,N,35,35" \
        @"^FDPurchase Confirmation^FS" \
        
        @"^FO50,180" \
        @"^A0,N,25,25" \
        @"^FDCustomer:^FS" \
        
        @"^FO225,180" \
        @"^A0,N,25,25" \
        @"^FDAcme Industries^FS" \
        
        @"^FO50,220" \
        @"^A0,N,25,25" \
        @"^FDDelivery Date:^FS" \
        
        @"^FO225,220" \
        @"^A0,N,25,25" \
        @"^FD%@^FS" \
        
        @"^FO50,273" \
        @"^A0,N,30,30" \
        @"^FDItem^FS" \
        
        @"^FO280,273" \
        @"^A0,N,25,25" \
        @"^FDPrice^FS" \
        
        @"^FO50,300" \
        @"^GB350,5,5,B,0^FS^XZ", dateString];
    
    [[printer getToolsUtil] sendCommand:header error:&error];


    NSString *body =
        @"^XA^DFR:MYBODY.ZPL^FS^POI^LL40" \
        @"^FO50,10" \
        @"^A0,N,28,28" \
        @"^FN1^FDproductName^FS" \
        
        @"^FO280,10" \
        @"^A0,N,28,28" \
        @"^FN2^FDproductPrice^FS" \
        @"^XZ";
    
    [[printer getToolsUtil] sendCommand:body error:&error];
    
    NSString *footer = 
        @"^XA^DFR:MYFOOTER.ZPL^FS^POI^LL600" \
        @"^FO50,1" \
        @"^GB350,5,5,B,0^FS" \
        
        @"^FO50,15"
        @"^A0,N,40,40" \
        @"^FDTotal^FS" \
        
        @"^FO175,15" \
        @"^A0,N,40,40" \
        @"^FN1^FDtotalPrice^FS" \
        
        @"^FO50,130" \
        @"^A0,N,45,45" \
        @"^FDPlease Sign Below^FS" \
        
        @"^FO50,190" \
        @"^GB350,200,2,B^FS" \
        
        @"^FO50,400" \
        @"^GB350,5,5,B,0^FS" \
        
        @"^FO50,420" \
        @"^A0,N,30,30" \
        @"^FDThanks for choosing us!^FS" \
        
        @"^FO50,470" \
        @"^B3N,N,45,Y,N" \
        @"^FD0123456^FS" \
        @"^XZ";

    [[printer getToolsUtil] sendCommand:footer error:&error];

    if(error != nil) {
        [self.connectivityViewController setStatus:[error localizedDescription] withColor:[UIColor redColor]];
    }
}

-(void)sendXml : (id<NSObject,ZebraPrinter>)printer {
    /*
     This routine demostrates how XML can be sent to the printer to recall and print ZPL formats.
     Notice that a separate XML format is sent for each section. And that the body section is sent multiple times, 1 for each line item.
     
     The format of the XML report is as follows :
     
        <?xml version="1.0" standalone="no"?>    //generic XML header
        <labels _FORMAT="_FORMAT NAME GOES HERE!__">  // the format name is the ZPL format on the printer
            <label>
                <variable name="myVariable">Data to print for the ZPL variable named 'myVariable'</variable>  //Optionally provide if the ZPL format contains ZPL variables
            </label>
        </labels>
    */
    NSError *error = nil;
    NSString *printHeaderXml =
        @"<?xml version=\"1.0\" standalone=\"no\"?>"\
        @"<labels _FORMAT=\"R:MYHEADER.ZPL\">"\
            @"<label>"\
            @"</label>"\
        @"</labels>";
    [[printer getToolsUtil] sendCommand:printHeaderXml error:&error];

    float totalPrice = 0;

    NSDictionary *fakeItems = @{@"Blender": [NSNumber numberWithFloat:34.99],
                                @"Sneakers (Size 7)": [NSNumber numberWithFloat:49.99],
                                @"Socks (3-pack)": [NSNumber numberWithFloat:9.99],
                                @"DVD Movie": [NSNumber numberWithFloat:14.99] };
    
    for (NSString *product in fakeItems) {
        NSNumber *price = fakeItems[product];
        totalPrice += price.floatValue;
        
        NSString *printBodyXml =
            @"<?xml version=\"1.0\" standalone=\"no\"?>"\
            @"<labels _FORMAT=\"R:MYBODY.ZPL\">"\
                @"<label>"\
                    @"<variable name=\"productName\">%@</variable>" \
                    @"<variable name=\"productPrice\">$%.2f</variable>" \
                @"</label>"\
            @"</labels>";
        
        NSString *xmlFormat = [NSString stringWithFormat:printBodyXml, product, price.floatValue];
        [[printer getToolsUtil] sendCommand:xmlFormat error:&error];

    }
    
    NSString *printFooterXml = [NSString stringWithFormat:
        @"<?xml version=\"1.0\" standalone=\"no\"?>"\
        @"<labels _FORMAT=\"R:MYFOOTER.ZPL\">"\
            @"<label>"\
                @"<variable name=\"totalPrice\">$%.2f</variable>" \
            @"</label>"\
        @"</labels>", totalPrice];
    [[printer getToolsUtil] sendCommand:printFooterXml error:&error];
    
    if(error != nil) {
        [self.connectivityViewController setStatus:[error localizedDescription] withColor:[UIColor redColor]];
    }
}

-(void)dealloc {
	[_connectivityViewController release];
    [_printButton release];
	[super dealloc];
}



@end
