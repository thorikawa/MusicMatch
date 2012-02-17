//
//  B4BoardView.h
//  BumpFour
//
//  Created by Jake on 10/13/09.
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
#import <AVFoundation/AVFoundation.h>
#import "B4BoardModel.h"
#import "B4RoundedLineView.h"

@protocol B4BoardViewDelegate <NSObject>
-(void) columnSelected:(int)colIdx;
@end

@interface B4BoardView : UIView {
	id<B4BoardViewDelegate> delegate;
	UIView *highlight;
	int highlightedSection;
	NSMutableArray *highlightRemoveQueue;
	B4RoundedLineView *gameWinLine;
	
	AVAudioPlayer *audio_row[10], *audio_end, *audio_done, *audio_win, *audio_lose;
}

@property (nonatomic, assign) id<B4BoardViewDelegate> delegate;
- (void) dropPiece:(Player)player row:(int)row column:(int)column;
- (void) highlightLineAtStartRow:(int)startRow startCol:(int)startCol endRow:(int)endRow endCol:(int)endCol;
- (void) resetBoardView;
- (void)audioPlayEnd;
- (void)audioPlayWin;
	
@end
