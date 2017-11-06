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

#import <UIKit/UIKit.h>
#import "ConnectionSetupController.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterConnection.h"

@interface ImagePrintDemoViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate> 

@property (nonatomic, retain) IBOutlet UITextField *pathOnPrinterTextField;
@property (nonatomic, retain) IBOutlet UISegmentedControl *printOrStoreToggle;
@property (nonatomic, assign) BOOL isStoreSelected;
@property (nonatomic, retain) NSString *pathOnPrinterText;
@property (nonatomic, retain) NSString *ipAddressText;
@property (nonatomic, retain) NSString *portAsStringText;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) ConnectionSetupController *connectivityViewController;
@property (nonatomic, retain) id<ZebraPrinterConnection, NSObject> connection;
@property (nonatomic, retain) id<ZebraPrinter, NSObject> printer;



-(IBAction)backgroundTap : (id)sender;
-(IBAction)printOrStoreToggleValueChanged : (id)sender;
-(IBAction)pdfButtonPressed : (id)sender;
-(IBAction)cameraButtonPressed : (id)sender;
-(IBAction)photoAlbumButtonPressed : (id)sender;
@end
