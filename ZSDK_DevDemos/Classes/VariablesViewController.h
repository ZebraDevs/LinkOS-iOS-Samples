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
#import "ZebraPrinter.h"
#import "VariableModifier.h"

@interface VariablesViewController : UIViewController<VariableModifier>

@property (nonatomic, retain) IBOutlet UITextField *printQuantity;
@property (nonatomic, retain) IBOutlet UIButton *printButton;
@property (nonatomic, retain) IBOutlet UITableView *variableFieldsView;
@property (nonatomic, retain) NSArray *dataFields;
@property (nonatomic, retain) NSMutableDictionary *dataValues;
@property (nonatomic, copy)  NSString *formatPath;
@property (nonatomic, retain) id<ZebraPrinter,NSObject> printer;

-(id)initWithFields:(NSArray*) fields withFormatPath:(NSString*)aformatPath andWithPrinter:(id<ZebraPrinter,NSObject>)aPrinter;
-(IBAction)buttonPressed:(id)sender;
-(IBAction)backgroundTap:(id)sender;

@end
