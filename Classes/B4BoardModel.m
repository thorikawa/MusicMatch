//
//  B4BoardModel.m
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

#import "B4BoardModel.h"

typedef enum BoardDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	DIAG_UP_LEFT,
	DIAG_UP_RIGHT,
	DIAG_DOWN_LEFT,
	DIAG_DOWN_RIGHT,
	
} BoardDirection;

@interface B4BoardModel (PrivateMethods)
- (void) checkForEndGameFromDrop:(int)column;
- (int)  countPiecesOfColor:(Player)color direction:(BoardDirection)UP fromRow:(int)row fromColumn:(int)column;
@end

@implementation B4BoardModel
-(void) resetBoard{
	if(columns != nil){
		[columns release];
		columns = nil;
	}
	
	NSMutableArray *tempCols = [NSMutableArray arrayWithCapacity:NUM_COLUMNS];
	for(int i = 0; i < NUM_COLUMNS; i++){
		NSMutableArray *column = [NSMutableArray arrayWithCapacity:NUM_ROWS];
		[tempCols addObject:column];
	}
	columns = (NSArray *)[tempCols retain];
	
	if(gameEndDictionary != nil){
		[gameEndDictionary release];
		gameEndDictionary = nil;
	}
	pieceCount = 0;
}

- (NSString *) description{
	NSMutableString *descr = [NSMutableString stringWithCapacity:100];
	[descr appendString:@"bump4board (appears rotated 90 CW):\n"];
	for(NSArray *column in columns){
		for(NSNumber *piece in column){
			[descr appendFormat:@"%d", [piece integerValue]];
		}
		[descr appendString:@"\n"];
	}
	[descr appendFormat:@"end bump4board.\n"];
	
	return descr;
}

- (id) init{
	if (self = [super init]){
		[self resetBoard];
	}
	
	return self;
}

-(Boolean) isColumnFull:(int)column{
	if(column < 0 || column >= NUM_COLUMNS){
		return YES;
	} else{
		NSMutableArray *column_array = [columns objectAtIndex:column];
		return ([column_array count] >= NUM_ROWS);
	}
}

-(Boolean) isBoardFull{
	return pieceCount >= (NUM_COLUMNS * NUM_ROWS);
}

-(Boolean) dropPiece:(Player)player column:(int)column{
	if([self isColumnFull:column]){
		return NO;
	} else {
		NSNumber *newPiece = [NSNumber numberWithInt:player];
		NSMutableArray *column_array = [columns objectAtIndex:column];
		[column_array addObject:newPiece];
		pieceCount++;
		[self checkForEndGameFromDrop:column];
		return YES;
	}
}
	
-(int) piecesInColumn:(int)col{
	//returns the number of pieces in each column
	if(col < 0 || col >= NUM_COLUMNS){
		return -1;
	}
	return [[columns objectAtIndex:col] count];
}

-(Player) colorAtRow:(int)row column:(int)column{
	if(column < 0 || column >= NUM_COLUMNS){
		return NOBODY_PLAYER;
	}
	NSMutableArray *column_array = [columns objectAtIndex:column];
	if([column_array count] <= row){
		return NOBODY_PLAYER;
	} else {
		NSNumber *num = (NSNumber *) [column_array objectAtIndex:row];
		return (Player)[num intValue];
	}
}

-(NSDictionary *) checkForGameEnd{
	return gameEndDictionary;
}

-(void) dealloc{
	[columns release];
	[gameEndDictionary release];
	[super dealloc];
}
@end
		
@implementation B4BoardModel (PrivateMethods)

- (int) countPiecesOfColor:(Player)color direction:(BoardDirection)direction fromRow:(int)row fromColumn:(int)column{
	Player curColor = [self colorAtRow:row column:column];
	if(curColor != color || curColor == NOBODY_PLAYER){
		return 0;
	} else {
		int newRow = row;
		int newCol = column;
		switch (direction) {
			case UP:
				newRow = row + 1;
				break;
			case DOWN:
				newRow = row - 1;
				break;
			case LEFT:
				newCol = column - 1;
				break;
			case RIGHT:
				newCol = column + 1;
				break;
			case DIAG_UP_LEFT:
				newRow = row + 1;
				newCol = column - 1;
				break;
			case DIAG_UP_RIGHT:
				newRow = row + 1;
				newCol = column + 1;
				break;
			case DIAG_DOWN_LEFT:
				newRow = row - 1;
				newCol = column - 1;
				break;
			case DIAG_DOWN_RIGHT:
				newRow = row - 1;
				newCol = column + 1;
				break;	
			default:
				break;
		}
		return 1 + [self countPiecesOfColor:color direction:direction fromRow:newRow fromColumn:newCol];
	}
}

- (void) checkForEndGameFromDrop:(int)column{
	//a win is always the result of the most recent drop
	//so we only need to check for lines extending from the most recent piece
	//only call this after a drop has occured and the new piece is added to the column array
	NSArray *column_array = [columns objectAtIndex:column];
	int row = [column_array count] - 1;
	
	Player color = [self colorAtRow:row column:column];
	int above = [self countPiecesOfColor:color direction:UP fromRow:row+1 fromColumn:column];
	int below = [self countPiecesOfColor:color direction:DOWN fromRow:row-1 fromColumn:column];
	int left = [self countPiecesOfColor:color direction:LEFT fromRow:row fromColumn:column-1];
	int right = [self countPiecesOfColor:color direction:RIGHT fromRow:row fromColumn:column+1];
	int diagUpLeft = [self countPiecesOfColor:color direction:DIAG_UP_LEFT fromRow:row+1 fromColumn:column-1];
	int diagUpRight = [self countPiecesOfColor:color direction:DIAG_UP_RIGHT fromRow:row+1 fromColumn:column+1];
	int diagDownLeft = [self countPiecesOfColor:color direction:DIAG_DOWN_LEFT fromRow:row-1 fromColumn:column-1];
	int diagDownRight = [self countPiecesOfColor:color direction:DIAG_DOWN_RIGHT fromRow:row-1 fromColumn:column+1];
	
	Boolean didEnd = NO;
	int winLineRowStart = -1;
	int winLineRowEnd = -1;
	int winLineColStart = -1;
	int winLineColEnd = -1;
	
	Player winner = color;
	if(above + below + 1 >= WIN_LINE_LEN){
		didEnd = YES;
		winLineRowStart = row - below;
		winLineRowEnd = row + above;
		winLineColStart = column;
		winLineColEnd = column;
	}else if(left + right + 1 >= WIN_LINE_LEN) {
		didEnd = YES;
		winLineRowStart = row;
		winLineRowEnd = row;
		winLineColStart = column - left;
		winLineColEnd = column + right;
	}else if(diagDownLeft + diagUpRight + 1 >= WIN_LINE_LEN) {
		didEnd = YES;
		winLineRowStart = row - diagDownLeft;
		winLineRowEnd = row + diagUpRight;
		winLineColStart = column - diagDownLeft;
		winLineColEnd = column + diagUpRight;
	}else if(diagDownRight + diagUpLeft + 1 >= WIN_LINE_LEN) {
		didEnd = YES;
		winLineRowStart = row - diagDownRight;
		winLineRowEnd = row + diagUpLeft;
		winLineColStart = column + diagDownRight;
		winLineColEnd = column  - diagUpLeft;
	} else if([self isBoardFull]){
		didEnd = YES;
		winner = NOBODY_PLAYER;
	}
	
	if(didEnd){
		//gameEndDictionary = [NSArray arr
		// <Key: @"GAME_WINNER", Val: (NSNumber *) containing Player enum. NOBODY indicating tie>
		// <Key: @"GAME_WINNING_LINE_START", Val: (NSArray *) of two (NSNumber *) describing the start index of the line that resulted in a win>
		// <Key: @"GAME_WINNING_LINE_END", Val: (NSArray *) of two (NSNumber *) describing the end index of the line that resulted in a win>>
		NSArray *winLineStartIdx = [NSArray arrayWithObjects:[NSNumber numberWithInt:winLineRowStart], [NSNumber numberWithInt:winLineColStart], nil];
		NSArray *winLineEndIdx = [NSArray arrayWithObjects:[NSNumber numberWithInt:winLineRowEnd], [NSNumber numberWithInt:winLineColEnd], nil];
		NSLog(@"Game Did End. winLineStartIdx:%@ winLineEndIdx:%@ winner:%d", winLineStartIdx, winLineEndIdx, winner);

		if(gameEndDictionary != nil){
			[gameEndDictionary release];
			gameEndDictionary = nil;
		}
		gameEndDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:winner], winLineStartIdx, winLineEndIdx, nil]
														forKeys:[NSArray arrayWithObjects:@"GAME_WINNER", @"GAME_WINNING_LINE_START", @"GAME_WINNING_LINE_END", nil]];
		
		[gameEndDictionary retain];
	}
}

@end
