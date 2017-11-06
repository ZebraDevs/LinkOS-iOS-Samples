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


@interface DrawingArea : UIView {
	NSMutableArray* listOfLines;
	CGPoint previousPoint;
	CGImageRef signatureImage;
	CGContextRef drawingAreaGraphicsContext;
	BOOL clearRequest;
}

@property (nonatomic, retain) NSMutableArray* listOfLines;
@property (nonatomic, assign) CGPoint previousPoint;
@property (nonatomic, assign) CGImageRef signatureImage;
@property (nonatomic, assign) CGContextRef drawingAreaGraphicsContext;
@property (nonatomic, assign) BOOL clearRequest;

-(void)awakeFromNib;
-(CGImageRef)getImage;
-(void) clearImage;

@end
