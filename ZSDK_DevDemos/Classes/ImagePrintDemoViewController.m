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

#import "ImagePrintDemoViewController.h"
#import "PrintPreviewController.h"
#import "ZebraPrinterConnection.h"
#import "TcpPrinterConnection.h"
#import "GraphicsUtil.h"
#import "ZebraPrinterFactory.h"
#import "MfiBtPrinterConnection.h"

@implementation ImagePrintDemoViewController

-(void)showErrorDialog :(NSString*)errorMessage {
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

- (void)viewDidLoad {
	self.title = @"Image Print";
	self.isStoreSelected = NO;
	[self.pathOnPrinterTextField setHidden:YES];
    
	self.connectivityViewController = [[[ConnectionSetupController alloc] init] autorelease];
	[self.view addSubview:self.connectivityViewController.view];
    [self.connectivityViewController.statusLabel setHidden:YES];

    [super viewDidLoad];
}

-(void) popupSpinner {
	self.loadingSpinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	[self.view addSubview:self.loadingSpinner];
    CGPoint spinnerCenter = self.view.center;
    spinnerCenter.y = spinnerCenter.y - 50;
    
	self.loadingSpinner.center = spinnerCenter;
	self.loadingSpinner.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | 
	UIViewAutoresizingFlexibleTopMargin | 
	UIViewAutoresizingFlexibleRightMargin | 
	UIViewAutoresizingFlexibleLeftMargin;
	[self.loadingSpinner startAnimating];
}

-(IBAction)printOrStoreToggleValueChanged : (id)sender {
	UISegmentedControl *control = sender;
	if (control.selectedSegmentIndex == 0) {
		[self.pathOnPrinterTextField setHidden:YES];
		self.isStoreSelected = NO;
	} else {
		[self.pathOnPrinterTextField setHidden:NO];
		self.isStoreSelected = YES;
	}
}


-(void)showError:(NSString *)errorString {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)showSuccessDialog:(NSString *)successMessage {
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:successMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(IBAction)cameraButtonPressed : (id)sender {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
		UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc]init]autorelease];
		imagePickerController.delegate = self;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		
        [self presentViewController:imagePickerController animated:YES completion:nil];
	} else {
		[self showError:@"This device does not have a camera"];
	}
}

-(IBAction)photoAlbumButtonPressed : (id)sender {
	UIImagePickerController *imagePickerController = [[[UIImagePickerController alloc]init]autorelease];
	imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
    [self presentViewController:imagePickerController animated:YES completion:nil];
}


-(BOOL) sendImageToPrinter:(UIImage *)image {
    if(!self.connectivityViewController.isBluetoothSelected) {
        self.ipAddressText = [self.connectivityViewController.ipDnsTextField text];
        self.portAsStringText = [self.connectivityViewController.portTextField text];
    }
    [self setZebraPrinter];
    BOOL success = NO;

    if(self.printer != nil) {
        id<GraphicsUtil, NSObject> graphicsUtil = [self.printer getGraphicsUtil];
        
        NSError *error = nil;
        if (self.isStoreSelected) {
            success = [graphicsUtil storeImage:self.pathOnPrinterText withImage:[image CGImage] withWidth:550 andWithHeight:412 error:&error];
        } else {
            success = [graphicsUtil printImage:[image CGImage] atX:0 atY:0 withWidth:550 withHeight:412 andIsInsideFormat:NO error:&error];
        }
    }
    return success;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
	[image retain];

    [self dismissViewControllerAnimated:YES completion:nil];
	
	self.pathOnPrinterText = self.pathOnPrinterTextField.text;
	
	[self popupSpinner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success = [self sendImageToPrinter:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (success == NO) {
                [self showErrorDialog:@"Error printing image"];
            } else {
                NSString *successMessage = (self.isStoreSelected == NO) ? @"Image sent to printer" : [NSString stringWithFormat:@"Stored image %@ to printer", self.pathOnPrinterText];
                [self showSuccessDialog:successMessage];
            }
            
        });
    });
}

-(IBAction)pdfButtonPressed : (id)sender {
    self.pathOnPrinterText = self.pathOnPrinterTextField.text;
    if(!self.connectivityViewController.isBluetoothSelected) {
       self.ipAddressText = [self.connectivityViewController.ipDnsTextField text];
       self.portAsStringText = [self.connectivityViewController.portTextField text];
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self setZebraPrinter];

        dispatch_async(dispatch_get_main_queue(), ^{
            PrintPreviewController *controller = [[[PrintPreviewController alloc] initWithPath:@"PDFDemo2.pdf"
                                                                             withStoreSelected:self.isStoreSelected
                                                                                   withPrinter:self.printer
                                                                              andPathOnPrinter:self.pathOnPrinterTextField.text] autorelease];
            [self.navigationController pushViewController:controller animated:YES];
            
        });
    });
    
}

-(IBAction)textFieldDoneEditing : (id)sender {
	[sender resignFirstResponder];
}

-(void)setZebraPrinter {
    if(self.connectivityViewController.isBluetoothSelected) {
        self.connection = [[[MfiBtPrinterConnection alloc] initWithSerialNumber:self.connectivityViewController.bluetoothPrinterLabel.text] autorelease];
    } else {
        int port = [self.portAsStringText intValue];
        self.connection = [[[TcpPrinterConnection alloc] initWithAddress:self.ipAddressText andWithPort:port] autorelease];
    }
    NSError *error = nil;
    [self.connection open];
    self.printer = [ZebraPrinterFactory getInstance:self.connection error:&error];
    if(error != nil) {
        [self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
    }
}

-(IBAction)backgroundTap : (id)sender {
	[self.connectivityViewController.ipDnsTextField resignFirstResponder];
	[self.connectivityViewController.portTextField	resignFirstResponder];
	[self.pathOnPrinterTextField resignFirstResponder];
}

-(void)dealloc {
    if(self.connection) {
        [self.connection close];
    }
    [_connection release];
	[_pathOnPrinterTextField release];
	[_printOrStoreToggle release];
	[_pathOnPrinterText release];
    [_ipAddressText release];
    [_portAsStringText release];
	[_loadingSpinner release];
    [_connectivityViewController release];
    [_printer release];
	[super dealloc];
}

@end
