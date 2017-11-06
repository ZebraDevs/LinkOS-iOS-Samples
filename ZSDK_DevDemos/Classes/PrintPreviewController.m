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

#import "PrintPreviewController.h"
#import "ZebraPrinterConnection.h"
#import "TcpPrinterConnection.h"
#import "GraphicsUtil.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"

@implementation PrintPreviewController

-(id)initWithPath:(NSString*)aPath withStoreSelected:(BOOL)isStoreSelected withPrinter:(id<ZebraPrinter, NSObject>)aPrinter andPathOnPrinter:(NSString*)aPathOnPrinter
{
    self = [super initWithNibName:@"PrintPreview" bundle:nil];
	self.path = aPath;
	self.storeSelected = isStoreSelected;
    self.pathOnPrinter = aPathOnPrinter;
	self.printer = aPrinter;
	return self;
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

- (void)viewDidLoad {
	self.title = @"Preview";
	
	CFURLRef url = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)self.path, NULL, NULL);
	NSURLRequest *request = [NSURLRequest requestWithURL:(NSURL*)url];
	[self.webView loadRequest:request];
	NSString* buttonTitle = self.storeSelected ? @"Store" : @"Print";
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:buttonTitle style:UIBarButtonItemStylePlain target:self action:@selector(print:)];
	[self.navigationItem setRightBarButtonItem:rightButton];
	[rightButton release];
	CFRelease(url);
    [super viewDidLoad];
}

-(UIImage *)imageFromPDF:(CGPDFDocumentRef)pdf 
					page:(NSUInteger)pageNumber {
	
	CGPDFPageRef page = CGPDFDocumentGetPage(pdf, pageNumber);
	
	CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFArtBox);
	
	UIImage *resultingImage = nil;
	
    UIGraphicsBeginImageContext(rect.size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	const CGFloat fillColors[] = {1, 1, 1, 1};
	
	CGColorRef colorRef = CGColorCreate(rgb, fillColors);
	CGContextSetFillColorWithColor(context, colorRef);
	CGContextFillRect(context, rect);
	CGColorSpaceRelease(rgb);
	CGColorRelease(colorRef);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	
	CGContextScaleCTM(context, 1.0, -1.0);
	
	if (page != NULL) {
		CGContextSaveGState(context);
		
		CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, rect, 0, true);
		
		CGContextConcatCTM(context, pdfTransform);
		
		CGContextDrawPDFPage(context, page);
		
		CGContextRestoreGState(context);
		
		resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	}
	
	UIGraphicsEndImageContext();
	
	return resultingImage;
}

-(void)showStoredSuccessMessage {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Image Stored" message:@"Stored pdf to printer" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)showStoredSuccessMessageOnGuiThread {
	[self performSelectorOnMainThread:@selector(showStoredSuccessMessage) withObject:nil waitUntilDone:YES];
}

-(void)enablePrintButton{
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

-(void)disablePrintButton{
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

-(NSString*) extendFileName:(NSString*)name withPageNumber:(NSInteger)pageNumber{
	NSString *pageNumberAsString = [NSString stringWithFormat:@"%ld", (long)pageNumber];
	
	NSInteger fileNameLength = 8 - [pageNumberAsString length];
	fileNameLength = (fileNameLength > [name length]) ? [name length] : fileNameLength;
	
	
	NSString *fileNameWithoutDrive = name;
	NSString *driveLetter = @"";
	
	NSArray *fileComponents = [name componentsSeparatedByString:@":"];
	if ([fileComponents count] > 1) {
		driveLetter = [NSString stringWithFormat:@"%@:", [fileComponents objectAtIndex:0]];
		fileNameWithoutDrive = [fileComponents objectAtIndex:1];
	}
    
    NSInteger tfnLength =(fileNameLength > [fileNameWithoutDrive length]) ? [fileNameWithoutDrive length] : fileNameLength;
    NSString *truncatedFileName = [fileNameWithoutDrive substringToIndex:tfnLength];
	
	return [NSString stringWithFormat:@"%@%@%@", driveLetter, truncatedFileName, pageNumberAsString];
}

-(void)showErrorDialog:(NSString *)errorString {
	[self enablePrintButton];
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)showSuccessDialog:(NSString *)successMessage {
	[self enablePrintButton];
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:successMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void)printPDF:(id<GraphicsUtil, NSObject>) graphicsUtil {
	
	CFURLRef pdfURL = CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)self.path, NULL, NULL);
	
	if (pdfURL != NULL) {
		CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)pdfURL);
		
		if (pdf == NULL) {
			[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:@"Could not retrieve PDF document." waitUntilDone:YES];
		} else {
			size_t nPages = CGPDFDocumentGetNumberOfPages(pdf);
			size_t pageNum;
			BOOL success = NO;
			for (pageNum = 1; pageNum <= nPages; pageNum++) {
				
				UIImage* image = [self imageFromPDF:pdf page:pageNum];
				if (nil == image) {
					[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:@"Could not render PDF document." waitUntilDone:YES];
					break;
				}
				
				NSError *error = nil;
				
				if (self.storeSelected) {
					NSString* effectiveName;
					if (nPages <= 1) {
						effectiveName = self.pathOnPrinter;
					} else {
						effectiveName = [self extendFileName:self.pathOnPrinter withPageNumber:pageNum];
					}
					success = [graphicsUtil storeImage:effectiveName withImage:[image CGImage] withWidth:-1 andWithHeight:-1 
					 error:&error];
				} else {
					success = [graphicsUtil printImage:[image CGImage] atX:0 atY:0 withWidth:-1 withHeight:-1 
					andIsInsideFormat:NO error:&error];
				}
				if(success == NO) {
					[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
					break;
				}
			}
			
			if (success == YES) {
				NSString *successMessage = (self.storeSelected == NO) ? @"Image sent to printer" : @"Stored pdf to printer";
				[self performSelectorOnMainThread:@selector(showSuccessDialog:) withObject:successMessage waitUntilDone:YES];
			}
			
			CGPDFDocumentRelease(pdf);
		}
		
		CFRelease(pdfURL);
	}
}


-(void) sendImageToPrinter {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSError *error = nil;
    if (self.printer != nil) {
        id<GraphicsUtil, NSObject> graphicsUtil = [self.printer getGraphicsUtil];
        [self printPDF:graphicsUtil];
    } else {
        [self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
    }
	

	[pool release];
}


-(void)print:(id)sender {
	NSString *fileExt = [self.path pathExtension];
	if ([[fileExt lowercaseString] isEqual:@"pdf"]) {
		[self disablePrintButton];
		[self popupSpinner];
		[NSThread detachNewThreadSelector:@selector(sendImageToPrinter) toTarget:self withObject:nil];
	} else {
		[self showErrorDialog:@"Can only print PDFs!"];
	}
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)dealloc {
	[_webView release];
	[_path release];
    [_pathOnPrinter release];
	[_loadingSpinner release];
	[_printer release];
    [super dealloc];
}

@end
