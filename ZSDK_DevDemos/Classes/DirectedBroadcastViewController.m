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

#import "DirectedBroadcastViewController.h"
#import "NetworkDiscoverer.h"
#import "DiscoveredPrintersViewController.h"

@implementation DirectedBroadcastViewController


- (void)viewDidLoad {
	self.title = @"Directed Broadcast";
	[super viewDidLoad];
}

-(void)buttonPressed:(id)sender {
	[self.discoveryParamTextField resignFirstResponder];
	[self startSpinner];
	NSString *range = self.discoveryParamTextField.text;
	[NSThread detachNewThreadSelector:@selector(doDiscovery:) toTarget:self withObject:range];
}

- (void) doDiscovery :(NSString*)range {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *error = nil;
	NSArray *printers = [NetworkDiscoverer directedBroadcastWithIpAddress:range error:&error];
    dispatch_async(dispatch_get_main_queue(), ^{[self stopSpinner];});

	if(printers != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *anotherViewController= [[DiscoveredPrintersViewController alloc] initWithPrinters:printers];
            
            [self.navigationController pushViewController:anotherViewController animated:YES];
            [anotherViewController release];
        });
	} else {
		[self performSelectorOnMainThread:@selector(showErrorDialog:) withObject:[error localizedDescription] waitUntilDone:YES];
	}
	
	[self setButtonState:YES];
	[pool release];
}

@end
