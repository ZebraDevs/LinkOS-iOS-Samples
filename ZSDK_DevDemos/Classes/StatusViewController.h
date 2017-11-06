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

#import <QuartzCore/QuartzCore.h>
#import "ConnectionSetupController.h"

@interface StatusViewController : UIViewController

@property (nonatomic,retain) IBOutlet UITextView *printerStatusText;
@property (nonatomic, retain) ConnectionSetupController *connectivityViewController;
@property (retain, nonatomic) IBOutlet UIButton *checkStatusButton;

-(IBAction)textFieldDoneEditing : (id)sender;
- (IBAction)checkStatusButtonPressed:(id)sender;



@end