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

#import "DiscoveryControllerBase.h"
#import "DiscoveredPrintersViewController.h"

@implementation DiscoveryControllerBase

@synthesize discoveryParamTextField;
@synthesize discoveryButton;
@synthesize spinner;

-(IBAction)backgroundTap : (id)sender {
	[self.discoveryParamTextField resignFirstResponder];
}

-(void)startSpinner {
	[self setButtonState:NO];
	self.spinner = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	CGRect mainBounds = [self.view bounds];
	[self.spinner setCenter:CGPointMake((mainBounds.size.width / 2), (mainBounds.size.height / 2))];
	[self.view addSubview:self.spinner];
	[self.spinner startAnimating];
}

-(void)stopSpinner {
	[self.spinner stopAnimating];
}


-(void)showErrorDialog :(NSString*)errorMessage {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Discovery Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void) setButtonState : (BOOL)state {
	[self performSelectorOnMainThread:@selector(setTestButtonStateSelector:) withObject:[NSNumber numberWithBool:state] waitUntilDone:NO];
}

- (void) setTestButtonStateSelector : (NSNumber*)state {
	[self.discoveryButton setEnabled:[state boolValue]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.discoveryParamTextField resignFirstResponder];
	[self buttonPressed:self];
	return YES;
}

- (void) viewDidLoad {
	self.discoveryParamTextField.delegate = self;
}

- (IBAction) buttonPressed:(id)sender {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)dealloc {
	[discoveryParamTextField release];
	[discoveryButton release];
    [spinner release];
    [super dealloc];
}

@end
