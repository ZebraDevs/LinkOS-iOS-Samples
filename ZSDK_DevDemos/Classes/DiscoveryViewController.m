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

#import "DiscoveryViewController.h"
#import "MulticastViewController.h"
#import "DirectedBroadcastViewController.h"
#import "DiscoveredPrintersViewController.h"
#import "SubnetSearchViewController.h"
#import "NetworkDiscoverer.h"

@implementation DiscoveryViewController

@synthesize listData;
@synthesize printers;
@synthesize spinner;

- (void)viewDidLoad {
    self.title = @"Discovery";
	
	NSArray *listItems = [[NSArray alloc]initWithObjects:@"Multicast", @"Directed Broadcast", @"Local Broadcast", @"Subnet Search",nil];
	
	self.listData = listItems;
	[listItems release];

	[super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [self.listData objectAtIndex:row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger row = [indexPath row];
	UIViewController *anotherViewController;
	
	switch (row) {
		case 0:
			anotherViewController = [[MulticastViewController alloc] initWithNibName:@"MulticastView" bundle:nil];
			break;
		case 1:
			anotherViewController = [[DirectedBroadcastViewController alloc] initWithNibName:@"DirectedBroadcastView" bundle:nil];
			break;
		case 2:
			[NSThread detachNewThreadSelector:@selector(doLocalBroadcast) toTarget:self withObject:nil];
			break;
		default:
			anotherViewController = [[SubnetSearchViewController alloc] initWithNibName:@"SubnetSearchView" bundle:nil];
			break;
 
	}
	 
	if (row != 2) {
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)doLocalBroadcast {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[self performSelectorOnMainThread:@selector(startSpinner) withObject:nil waitUntilDone:YES];
	self.printers = [NetworkDiscoverer localBroadcast:nil];
	[self performSelectorOnMainThread:@selector(stopSpinner) withObject:nil waitUntilDone:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *anotherViewController = [[DiscoveredPrintersViewController alloc] initWithPrinters:self.printers];
        [self.navigationController pushViewController:anotherViewController animated:YES];
        [anotherViewController release];
    });
	[pool release];
}

-(void)startSpinner {
	self.spinner = [[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
	CGRect mainBounds = [self.view bounds];
	[self.spinner setCenter:CGPointMake((mainBounds.size.width / 2), (mainBounds.size.height / 2))];
	[self.view addSubview:self.spinner];
	[self.spinner startAnimating];
}

-(void)stopSpinner {
	[spinner stopAnimating];
}

- (void)dealloc {
	[listData release];
	[printers release];
    [spinner release];
    [super dealloc];
}

@end
