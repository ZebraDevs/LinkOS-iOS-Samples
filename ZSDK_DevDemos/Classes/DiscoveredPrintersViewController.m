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

#import "DiscoveredPrintersViewController.h"
#import "DiscoveredPrinter.h"

@implementation DiscoveredPrintersViewController

@synthesize listData;

-(DiscoveredPrintersViewController*)initWithPrinters:(NSArray*)printers {
    self = [super initWithNibName:@"DiscoveredPrintersView" bundle:nil];
	self.title = [NSString stringWithFormat:@"Found %lu Printers",(unsigned long)[printers count]];
	NSMutableArray *objs = [[NSMutableArray alloc]init];
	for(DiscoveredPrinter *d in printers) {
		[objs addObject:d.address];
	}
	[objs addObject:@""];
	self.listData = objs;
	[objs release];
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSUInteger row = [indexPath row];
	cell.textLabel.text = [self.listData objectAtIndex:row];
    return cell;
}


- (void)dealloc {
	[listData release];
    [super dealloc];
}


@end