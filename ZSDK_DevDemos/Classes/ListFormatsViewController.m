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

#import "ListFormatsViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"
#import "VariablesViewController.h"
#import "FieldDescriptionData.h"


@implementation ListFormatsViewController

@synthesize printerFormats;
@synthesize printer;

-(id)initWithFormats:(NSArray*)formats andPrinter:(id<ZebraPrinter,NSObject>)aPrinter {
    self = [super initWithNibName:@"ListFormatsView" bundle:nil];
	self.printer = aPrinter;
	self.printerFormats = formats;
	return self;
}

- (void)viewDidLoad {
	self.title = @"Formats";
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.printerFormats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.imageView.image = [UIImage imageNamed:@"rw420.jpg"];
	cell.textLabel.text = [self.printerFormats objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryNone;
	
    return cell;
}

- (void)dealloc {
	[printerFormats release];
	[printer release];
    [super dealloc];
}


@end
