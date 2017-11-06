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
#import "ZebraPrinter.h"
#import "ConnectionSetupController.h"
#import "DrawingArea.h"

@interface SignatureCaptureDemoViewController : UIViewController

@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) IBOutlet DrawingArea *signatureArea;
@property (nonatomic, retain) ConnectionSetupController *connectivityViewController;
@property (retain, nonatomic) IBOutlet UIButton *printSignatureButton;

-(IBAction)buttonPressed:(id)sender;
-(IBAction)textFieldDoneEditing : (id)sender;

@end
