//
//  B4BoardModel.h
//  BumpFour
//
//  Created by Jake on 10/12/09.
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

#import <Foundation/Foundation.h>
#define WIN_LINE_LEN 4
#define NUM_COLUMNS 7
#define NUM_ROWS 6

typedef enum Player {
	NOBODY_PLAYER = -1,
	RED_PLAYER = 0,
	BLACK_PLAYER = 1
} Player;

@interface B4BoardModel : NSObject {
	NSArray *columns;
	NSDictionary *gameEndDictionary;
	int pieceCount;
}

-(void) resetBoard;
-(Boolean) isColumnFull:(int)column;
-(Boolean) isBoardFull;
-(Boolean) dropPiece:(Player)player column:(int)column;
-(int) piecesInColumn:(int)col;
//checkForGameEnd returns a dictionary describing the winning condition or nil if the game is not over
// <Key: @"GAME_WINNER", Val: (NSNumber *) containing Player enum. NOBODY indicating tie>
// <Key: @"GAME_WINNING_LINE_START", Val: (NSArray *) of two (NSNumber *) describing the start index of the line that resulted in a win>
// <Key: @"GAME_WINNING_LINE_END", Val: (NSArray *) of two (NSNumber *) describing the end index of the line that resulted in a win>>
-(NSDictionary *) checkForGameEnd;

@end