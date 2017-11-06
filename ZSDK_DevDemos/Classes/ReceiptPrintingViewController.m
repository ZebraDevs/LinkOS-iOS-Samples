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

#import "ReceiptPrintingViewController.h"
#import "ZebraPrinterConnection.h"
#import "TcpPrinterConnection.h"
#import "MfiBtPrinterConnection.h"
#import "ZebraPrinterFactory.h"


@implementation ReceiptPrintingViewController

- (void)viewDidLoad {
	self.title = @"Receipt Printing";
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

- (IBAction)printReceiptAsOneJobButtonPressed:(id)sender {
    [self.receiptPrintButtonAsOneJob setEnabled:NO];
    [self.receiptPrintButtonAsManyJobs setEnabled:NO];
    
    [NSThread detachNewThreadSelector:@selector(performReceiptPrintingDemo:) toTarget:self withObject:[NSNumber numberWithBool:NO]];
}

- (IBAction)printReceiptAsManyJobsButtonPressed:(id)sender {
    [self.receiptPrintButtonAsOneJob setEnabled:NO];
    [self.receiptPrintButtonAsManyJobs setEnabled:NO];
    
    [NSThread detachNewThreadSelector:@selector(performReceiptPrintingDemo:) toTarget:self withObject:[NSNumber numberWithBool:YES]];
}

- (void) performReceiptPrintingDemo: (NSNumber*)printAsManyJobs {
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
        [self.connectivityViewController setStatus:@"Determining Printer Language..." withColor:[UIColor yellowColor]];
        
        NSError *error = nil;
        id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
        
        if(printer != nil) {
            PrinterLanguage language = [printer getPrinterControlLanguage];
            [self.connectivityViewController setStatus:[NSString stringWithFormat:@"Printer Language %@",[self getLanguageName:language]] withColor:[UIColor cyanColor]];
            if(language == PRINTER_LANGUAGE_CPCL) {
                [self.connectivityViewController setStatus:@"This demo will not work for CPCL printers!" withColor:[UIColor redColor]];
            } else {
                [self.connectivityViewController setStatus:@"Building receipt in ZPL..." withColor:[UIColor cyanColor]];

                if(printAsManyJobs.boolValue) {
                    [self.connectivityViewController setStatus:@"Sending receipt as many jobs to printer" withColor:[UIColor cyanColor]];
                    [self printReceiptAsManyJobs:printer];
                } else {
                    [self.connectivityViewController setStatus:@"Sending receipt as one job to printer" withColor:[UIColor cyanColor]];

                    NSString *sampleZplReceipt = [self createZplReceipt];
                    [self printReceiptAsOneJobUsingNSString:printer withString:[sampleZplReceipt mutableCopy]];

//                    Alternative method to show how to send large amounts of data as NSData using the PrinterConnection write method.
//                    NSData *sampleZplReceiptAsNsData = [sampleZplReceipt dataUsingEncoding:NSASCIIStringEncoding];
//                    [self printReceiptAsOneJobUsingNSData:connection withData:[sampleZplReceiptAsNsData mutableCopy]];
                }
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
	
    [self.receiptPrintButtonAsOneJob setEnabled:YES];
    [self.receiptPrintButtonAsManyJobs setEnabled:YES];
	[pool release];
}

-(void)printReceiptAsOneJobUsingNSString:(id<NSObject,ZebraPrinter>)printer withString:(NSMutableString*)fullLabel {
    /*
     Sending large amounts of data in a single write command can overflow the NSStream buffers which are the underlying mechanism used by the SDK to communicate with the printers. 
     This method shows one way to break up large strings into smaller chunks to send to the printer
     */
    NSError *error = nil;
    
    long blockSize = 1024;
    long totalSize = fullLabel.length;
    long bytesRemaining = totalSize;
    
    while (bytesRemaining > 0) {
        long bytesToSend = MIN(blockSize, bytesRemaining);
        NSRange range = NSMakeRange(0, bytesToSend);
        
        NSString *partialLabel = [fullLabel substringWithRange:range];
        
        [[printer getToolsUtil] sendCommand:partialLabel error:&error];
        
        bytesRemaining -= bytesToSend;
        
        [fullLabel deleteCharactersInRange:range];
        
    }
    if(error != nil) {
        [self.connectivityViewController setStatus:[error localizedDescription] withColor:[UIColor redColor]];
    }
}

-(void)printReceiptAsOneJobUsingNSData:(id<NSObject,ZebraPrinterConnection>)connection withData:(NSMutableData*)fullLabel {
    /*
     Sending large amounts of data in a single write command can overflow the NSStream buffers which are the underlying mechanism used by the SDK to communicate with the printers.
     This method shows one way to break up large data into smaller chunks to send to the printer
     */
    NSError *error = nil;
    
    long blockSize = 1024;
    long totalSize = fullLabel.length;
    long bytesRemaining = totalSize;
    
    while (bytesRemaining > 0) {
        long bytesToSend = MIN(blockSize, bytesRemaining);
        NSRange range = NSMakeRange(0, bytesToSend);
        
        NSData *partialLabel = [fullLabel subdataWithRange:range];
        [connection write:partialLabel error:&error];
                
        bytesRemaining -= bytesToSend;
        
        [fullLabel replaceBytesInRange:range withBytes:NULL length:0];
    }
    if(error != nil) {
        [self.connectivityViewController setStatus:[error localizedDescription] withColor:[UIColor redColor]];
    }
}

-(NSString*)createZplReceipt {
    /*
     This routine is provided to you as an example of how to create a variable length label with user specified data.
     The basic flow of the example is as follows

        Header of the label with some variable data
        Body of the label
            Loops thru user content and creates small line items of printed material
        Footer of the label
     
     As you can see, there are some variables that the user provides in the header, body and footer, and this routine uses that to build up a proper ZPL string for printing.
     Using this same concept, you can create one label for your receipt header, one for the body and one for the footer. The body receipt will be duplicated as many items as there are in your variable data
     
     */
    
    NSString *tmpHeader =
        /*
         Some basics of ZPL. Find more information here : http://www.zebra.com/content/dam/zebra/manuals/en-us/printer/zplii-pm-vol2-en.pdf
                  
         ^XA indicates the beginning of a label
         ^PW sets the width of the label (in dots)
         ^MNN sets the printer in continuous mode (variable length receipts only make sense with variably sized labels)
         ^LL sets the length of the label (we calculate this value at the end of the routine)
         ^LH sets the reference axis for printing. 
            You will notice we change this positioning of the 'Y' axis (length) as we build up the label. Once the positioning is changed, all new fields drawn on the label are rendered as if '0' is the new home position
         ^FO sets the origin of the field relative to Label Home ^LH
         ^A sets font information 
         ^FD is a field description
         ^GB is graphic boxes (or lines)
         ^B sets barcode information
         ^XZ indicates the end of a label
         */
        @"^XA^PON^PW400^MNN^LL%d^LH0,0" \
    
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
        @"^GB350,5,5,B,0^FS";

    int headerHeight = 325;
    NSMutableString *body = [NSMutableString stringWithFormat:@"^LH0,%d", headerHeight];
    
    int heightOfOneLine = 40;
    
    float totalPrice = 0;
    
    for (int i = 0; i < self.itemsToPrint.count; i++) {
        NSDictionary *item = [self.itemsToPrint objectAtIndex:i];
        NSString *productName = item.allKeys[0];
        NSNumber *price = item[productName];
        NSString *lineItem =
            @"^FO50,%d"\
            @"^A0,N,28,28"\
            @"^FD%@^FS"\
        
            @"^FO280,%d"\
            @"^A0,N,28,28"\
            @"^FD$%@^FS";
        totalPrice += price.floatValue;
        
        [body appendString:[NSString stringWithFormat:lineItem, i * heightOfOneLine, productName, i * heightOfOneLine, price]];
    }
    
    long totalBodyHeight = (self.itemsToPrint.count + 1) * heightOfOneLine;

    long footerStartPosition = headerHeight + totalBodyHeight;
    
    NSString *footer = [NSString stringWithFormat:
        @"^LH0,%ld" \
    
        @"^FO50,1" \
        @"^GB350,5,5,B,0^FS" \
    
        @"^FO50,15" 
        @"^A0,N,40,40" \
        @"^FDTotal^FS" \
    
        @"^FO175,15" \
        @"^A0,N,40,40" \
        @"^FD$%.2f^FS" \
    
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
        @"^XZ", footerStartPosition, totalPrice];
    
    long footerHeight = 600;
    long labelLength = headerHeight + totalBodyHeight + footerHeight;
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *header = [NSString stringWithFormat:tmpHeader, labelLength, dateString];
    
    NSString *wholeZplLabel = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
    
    return wholeZplLabel;
}

-(void)printReceiptAsManyJobs:(id<NSObject,ZebraPrinter>)printer {
    NSError *error = nil;

    /*
        This routine is provided to you as an example of how to create a variable length label with user specified data using multiple formats.
        The basic flow of the example is as follows

            Header of the label with some variable data
            Body of the label
                Loops thru user content and creates small line items of printed material
            Footer of the label

        As you can see, there are some variables that the user provides in the header, body and footer, and this routine uses that to build up a proper ZPL string for printing.
        Using this same concept, you can create one label for your receipt header, one for the body and one for the footer. The body receipt will be duplicated as many items as there are in your variable data.
        Note : This method uses multiple ZPL formats to create one "recetipt" (A format is defined as starting with a '^XA' and ending with a '^XZ'.
            A format is a self contained "job". If multiple applications are printing many formats simultaneously, you may get interspersed formats from the different origins.
            In order to avoid this, you need to either :
                Only allow 1 application to communicate with the printer at one time
                Use the other method to create only 1 format
        The benefits of this method are that you can start printing part of the label while your application is creating content for the next part of the label
            i.e. Send the header contents to the printer to render and print while generating many line items for the body and/or footer
     
     */
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    

    NSString *header = [NSString stringWithFormat:
        @"^XA^POI^PW400^MNN^LL325^LH0,0" \
        
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
    
    
    
    float totalPrice = 0;
    
    for (int i = 0; i < self.itemsToPrint.count; i++) {
        NSDictionary *item = [self.itemsToPrint objectAtIndex:i];
        NSString *productName = item.allKeys[0];
        NSNumber *price = item[productName];
        NSString *lineItem =
            @"^XA^POI^LL40" \
            @"^FO50,10"\
            @"^A0,N,28,28"\
            @"^FD%@^FS"\
            
            @"^FO280,10"\
            @"^A0,N,28,28"\
            @"^FD$%@^FS" \
            @"^XZ";
        totalPrice += price.floatValue;
        
        NSString *lineItemWithVars = [NSString stringWithFormat:lineItem, productName, price];
        [[printer getToolsUtil] sendCommand:lineItemWithVars error:&error];
    }
    
        
    NSString *footer = [NSString stringWithFormat:
            @"^XA^POI^LL600" \
            @"^FO50,1" \
            @"^GB350,5,5,B,0^FS" \
            
            @"^FO50,15"
            @"^A0,N,40,40" \
            @"^FDTotal^FS" \
            
            @"^FO175,15" \
            @"^A0,N,40,40" \
            @"^FD$%.2f^FS" \
            
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
            @"^XZ", totalPrice];
    
    [[printer getToolsUtil] sendCommand:footer error:&error];

    if(error != nil) {
        [self.connectivityViewController setStatus:[error localizedDescription] withColor:[UIColor redColor]];
    }
}

-(NSString*) getLanguageName :(PrinterLanguage)language {
	if(language == PRINTER_LANGUAGE_ZPL){
		return @"ZPL";
	} else {
		return @"CPCL";
	}
}

-(void)dealloc {
	[_connectivityViewController release];
    [_receiptPrintButtonAsOneJob release];
    [_itemsToPrint release];
    [_receiptPrintButtonAsManyJobs release];
	[super dealloc];
}

- (void)viewDidUnload {
    [self setReceiptPrintButtonAsManyJobs:nil];
    [super viewDidUnload];
}
@end
