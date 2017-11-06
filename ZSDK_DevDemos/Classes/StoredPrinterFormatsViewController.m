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

#import "StoredPrinterFormatsViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"
#import "VariablesViewController.h"
#import "FieldDescriptionData.h"


@implementation StoredPrinterFormatsViewController

-(void)showErrorDialog :(NSString*)errorMessage {
	[self.loadingSpinner stopAnimating];
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
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

-(id)initWithFormats:(NSArray*)formats andWithPrinter:(id<ZebraPrinter,NSObject>) aPrinter {
    self = [super initWithNibName:@"StoredPrinterFormatsView" bundle:nil];
    self.printerFormats = formats;
    self.printer = aPrinter;
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
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}


-(void) getVariablesFromFormatOnSeperateThread:(NSString *)formatPath {
	NSError *error = nil;
    if (self.printer != nil) {
        id<FormatUtil, NSObject> formatUtil = [self.printer getFormatUtil];
        
        NSData *formatContents = [formatUtil retrieveFormatFromPrinterWithPath:formatPath error:&error];
        if (formatContents != nil) {
            NSString *contentsAsString = [[[NSString alloc]initWithData:formatContents encoding:NSUTF8StringEncoding]autorelease];
            self.variables = [formatUtil getVariableFieldsWithFormatContents:contentsAsString error:&error];
        }
     } 
}

-(void)pushVariableFieldEditController:(NSString *)formatPath {
	[self.loadingSpinner stopAnimating];
	VariablesViewController *controller = [[VariablesViewController alloc]initWithFields:self.variables withFormatPath:formatPath andWithPrinter:self.printer];
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *formatPath = [self.printerFormats objectAtIndex:indexPath.row];
	[self popupSpinner];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.variables = nil;
        [self getVariablesFromFormatOnSeperateThread:formatPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.variables != nil) {
                [self pushVariableFieldEditController:formatPath];
            } else {
                [self showErrorDialog:@"Error retrieving variables"];
            }
        });
    });

}

- (void)dealloc {
	[_printerFormats release];
	[_variables release];
	[_loadingSpinner release];
    [_printer release];
    [super dealloc];
}


@end

