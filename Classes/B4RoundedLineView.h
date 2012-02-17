//
//  B4RoundedLineView.h
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

#import <UIKit/UIKit.h>

//This is a view that is overlayed over the game board to draw a line connecting the winning pieces.
@interface B4RoundedLineView : UIView {
	int startX;
	int startY;
	int endX;
	int endY;
}

@property (nonatomic, assign) int startX;
@property (nonatomic, assign) int startY;
@property (nonatomic, assign) int endX;
@property (nonatomic, assign) int endY;

@end
