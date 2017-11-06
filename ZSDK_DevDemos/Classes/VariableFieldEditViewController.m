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

#import "VariableFieldEditViewController.h"
#import "ZSDKDeveloperDemosAppDelegate.h"
#import "VariablesViewController.h"

@implementation VariableFieldEditViewController

@synthesize fieldDescriptionData;
@synthesize variableModifier;
@synthesize editTextField;

 
-(id)initWithFieldDescriptionData:(FieldDescriptionData*) aFieldNameAndData andValue:(NSString*)value andWithVariableModifier:(id<VariableModifier, NSObject>)aVariableModifier {
    self = [super initWithNibName:@"VariableFieldEditView" bundle:nil];
    self.variableModifier = aVariableModifier;
    self.fieldDescriptionData = aFieldNameAndData;
    self.title = self.fieldDescriptionData.fieldName ? self.fieldDescriptionData.fieldName :[NSString stringWithFormat:@"Field %@", self.fieldDescriptionData.fieldNumber];
    self.editTextField = [[UITextField new]autorelease];
    self.editTextField.text = value;
    self.editTextField.delegate = self;
	
	return self;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self.editTextField resignFirstResponder];
	[self.navigationController popViewControllerAnimated:YES];
	return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
	[self.variableModifier setVariableValue:self.editTextField.text forFieldNumber:self.fieldDescriptionData.fieldNumber];
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
	CGRect rectOfEditField = cell.frame;
	rectOfEditField.origin.x += 15;
	rectOfEditField.origin.y += 3;
	rectOfEditField.size.width -= 20;
	rectOfEditField.size.height -= 6;
	
	self.editTextField.frame = rectOfEditField;
	[self.editTextField setFont:[UIFont systemFontOfSize:30]];
	self.editTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	self.editTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
	[cell.contentView addSubview:self.editTextField];
	[self.editTextField becomeFirstResponder];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)dealloc {
	[editTextField release];
	[fieldDescriptionData release];
	[variableModifier release];
    [super dealloc];
}


@end

