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

#import "DrawingArea.h"


@interface LineSegment : NSObject {
	CGPoint start;
	CGPoint end;
}

@property(nonatomic,assign) CGPoint start;
@property(nonatomic,assign) CGPoint end;

-(id) init:(CGPoint)aStart withEnd:(CGPoint)anEnd;

@end


@implementation LineSegment

@synthesize start;
@synthesize end;

-(id) init:(CGPoint)aStart withEnd:(CGPoint)anEnd{
    self = [super init];
	self.start = aStart;
	self.end = anEnd;
	return self;
}

@end


@implementation DrawingArea

@synthesize listOfLines;
@synthesize previousPoint;
@synthesize signatureImage;
@synthesize drawingAreaGraphicsContext;
@synthesize clearRequest;

- (void)awakeFromNib {
	self.listOfLines = [NSMutableArray arrayWithCapacity:11];
	self.drawingAreaGraphicsContext =  nil;
	self.clearRequest = YES;
}

- (void) drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	if (self.clearRequest) {
		CGFloat gray[4] = {0.95f, 0.95f, 0.95f, 1.0f};
		CGContextSetFillColor(context, gray);
		CGContextFillRect(context, self.bounds);
		self.clearRequest = NO;
	}
	
    CGFloat black[4] = {0.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(context, black);
	for(LineSegment* line in self.listOfLines){
		CGContextBeginPath(context);
		CGPoint startPoint = line.start;
		CGPoint endPoint = line.end;
		CGContextMoveToPoint(context, startPoint.x, startPoint.y);
		CGContextAddLineToPoint(context, endPoint.x, endPoint.y);
		CGContextStrokePath(context);
	}
	if (self.signatureImage != nil) {
		CGImageRelease(self.signatureImage);
		self.signatureImage = nil;
	}
	self.signatureImage = CGBitmapContextCreateImage(context);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.previousPoint = [[touches anyObject] locationInView:self];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint currPoint = [[touches anyObject] locationInView:self];
	LineSegment* line = [[LineSegment alloc] init:self.previousPoint withEnd:currPoint];
	[self.listOfLines addObject:line];
	self.previousPoint = currPoint;
	[line release];
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint currPoint = [[touches anyObject] locationInView:self];
	LineSegment* line = [[LineSegment alloc] init:self.previousPoint withEnd:currPoint];
	[self.listOfLines addObject:line];
	[line release];
	[self setNeedsDisplay];
}

-(CGImageRef) getImage{
	return self.signatureImage;
}

-(void) clearImage{
	self.clearRequest = YES;
	[self.listOfLines removeAllObjects];
	[self setNeedsDisplay];
}

- (void)dealloc {
	[listOfLines release];
	if (self.signatureImage != nil) {
		CGImageRelease(self.signatureImage);
		self.signatureImage = nil;
	}	
    [super dealloc];
}

@end
