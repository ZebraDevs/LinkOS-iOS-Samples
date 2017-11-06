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
#import "FieldDescriptionData.h"
#import "VariableModifier.h"

@interface VariableFieldEditViewController : UITableViewController <UITextFieldDelegate> {
	FieldDescriptionData *fieldDescriptionData;
	id	delegate;
    UITextField *editTextField;
	id<VariableModifier, NSObject> variableModifier;
}

@property (nonatomic, retain) FieldDescriptionData *fieldDescriptionData;
@property (nonatomic, retain) id<VariableModifier, NSObject> variableModifier;
@property (nonatomic, retain) UITextField *editTextField;

-(id)initWithFieldDescriptionData:(FieldDescriptionData*) aFieldNameAndData andValue:(NSString*)value andWithVariableModifier:(id<VariableModifier, NSObject>)aVariableModifier;

@end
