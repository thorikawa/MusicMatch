//
//  B4RoundedLineView.m
//  BumpFour
//
//  Created by Jake on 10/14/09.
//
//  Copyright 2010, Bump Technologies, Inc. All rights reserved.  Use of the 
//  software programs described herein is subject to applicable license agreements 
//  and nondisclosure agreements. Unless specifically otherwise agreed in
//  writing, all rights, title, and interest to this software and
//  documentation remain with Bump Technologies, Inc. Unless expressly
//  agreed in a signed license agreement, Bump Technologies makes no
//  representations about the suitability of this software for any purpose
//  and it is provided "as is" without express or implied warranty.
//  

#import "B4RoundedLineView.h"


@implementation B4RoundedLineView
@synthesize startX, startY, endX, endY;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		[self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext(); //get the graphics context
	
	CGContextSetLineCap(ctx, kCGLineCapRound);
	
	//make a white line that's a bit wider to have an outline
	CGContextSetLineWidth(ctx, 8.0);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	//now we build a "path"
	CGContextMoveToPoint(ctx, startX, startY);
	CGContextAddLineToPoint( ctx, endX, endY);
	//"stroke" the path
	CGContextStrokePath(ctx);
	
	//draw a slightly slimmer blue line over it
	CGContextSetLineWidth(ctx, 6.0);
	CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:0.44 green:0.5 blue:0.85 alpha:1.0] CGColor]); // colorcolor
	//now we build a "path"
	CGContextMoveToPoint(ctx, startX, startY);
	CGContextAddLineToPoint( ctx, endX, endY);
	//"stroke" the path
	CGContextStrokePath(ctx);
}


- (void)dealloc {
    [super dealloc];
}


@end
