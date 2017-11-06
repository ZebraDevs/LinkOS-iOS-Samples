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

#import "RootViewController.h"
#import "DemoListViewController.h"

@implementation RootViewController

@synthesize listData;

- (void)viewDidLoad {
    
	self.navigationController.navigationBar.translucent = NO;
	NSArray *listItems = [[NSArray alloc]initWithObjects:@"Start", nil];

	self.listData = listItems;
	[listItems release];
    
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	self.listData = nil;
	[super viewDidUnload];
}


#pragma mark Table view methods

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
	cell.textLabel.text = [listData objectAtIndex:row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSUInteger row = [indexPath row];
	UIViewController *anotherViewController = nil;
	switch (row) {
		case 0:
            anotherViewController = [[DemoListViewController alloc]init];
			break;
		default:
			break;
	}
	if (anotherViewController != nil) {
		[self.navigationController pushViewController:anotherViewController animated:YES];
		[anotherViewController release];
	}
}

- (void)dealloc {
	[listData release];
    [super dealloc];
}


@end

