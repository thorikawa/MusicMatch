//
//  B4BoardView.m
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

#import "B4BoardView.h"
@implementation B4BoardView
@synthesize delegate;

#define PIECE_TAG 1001

#define FIRST_HOLE_X_OFFSET 8 // was 8
#define FIRST_HOLE_Y_OFFSET 8 // was 7
#define HOLE_X_SPACING 45
#define HOLE_Y_SPACING 46

#define LINE_OFFSET_X 2 // 1
#define LINE_OFFSET_Y -4 // -3

-(void) resetBoardView{
	for(UIView *view in [self subviews]){
		if(view.tag == PIECE_TAG){
			[view removeFromSuperview];
		}
	}
	if([gameWinLine superview] != nil){
		[gameWinLine removeFromSuperview];
	}
}

- (id)initWithCoder:(NSCoder *)decoder{
	if (self = [super initWithCoder:decoder]) {
		NSLog(@"init with coder");
		[self setBackgroundColor:[UIColor clearColor]];
		UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bump4boardNew.png"]];
		[bg setFrame:self.bounds];
				
		[self addSubview:bg];
		[bg release];
		highlightedSection = -1;
		highlightRemoveQueue = [[NSMutableArray alloc] initWithCapacity:NUM_COLUMNS];
		
		gameWinLine = [[B4RoundedLineView alloc] initWithFrame:self.bounds];

		// allocate sounds
		NSError *audio_error;
		if (!audio_row[0]) audio_row[0] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row0" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		if (!audio_row[1]) audio_row[1] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row1" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		if (!audio_row[2]) audio_row[2] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row2" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		if (!audio_row[3]) audio_row[3] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row3" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		if (!audio_row[4]) audio_row[4] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row4" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		if (!audio_row[5]) audio_row[5] = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_row5" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		audio_end = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_quit_game_button" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		audio_end.volume = 0.5;
		audio_win = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sounds_youwin" ofType:@"mp3" inDirectory:@"/"]] error:&audio_error ];
		audio_win.volume = 0.5;
	}
	for (int i=0;i<6; i++) {
		audio_row[i].volume = 0.5;
		[audio_row[i] prepareToPlay];
	}
	return self;
}

- (void)audioPlayEnd {
	[audio_end play];
}

- (void)audioPlayWin {
	[audio_win play];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

#pragma mark -
#pragma mark Selection & Highlighting
-(int) sectionForPosition:(CGPoint)position{
	int posX = position.x;
	if(posX < 0 || posX >= self.frame.size.width){
		return -1;
	}
	
	int sectionWidth = (int)(self.frame.size.width / NUM_COLUMNS);
	int sectionForPos = (int)(posX / sectionWidth);
	return sectionForPos;
}

- (void) removeHighlight{
	if(highlight){
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(removeHighlightAnimationEnd)];
		[UIView setAnimationDuration:0.2];
		[highlight setAlpha:0.0];
		[UIView commitAnimations];
		[highlightRemoveQueue addObject:highlight];
		[highlight release];
		highlight = nil;
		highlightedSection = -1;
	}
}

- (void) removeHighlightAnimationEnd{
	[(UIView *)[highlightRemoveQueue objectAtIndex:0] removeFromSuperview];
	[highlightRemoveQueue removeObjectAtIndex:0];
}

- (void) updateHightlightForPostion:(CGPoint)position{
	int sectionForPos = [self sectionForPosition:position];
	
	if(sectionForPos < 0 || sectionForPos >= NUM_COLUMNS){
		[self removeHighlight];
		return;
	}
	
	if(highlightedSection != sectionForPos){
		if(highlight){
			[self removeHighlight];
		}
		int sectionWidth = (int)(self.frame.size.width / NUM_COLUMNS);
		int highlightX = (int)(sectionForPos * sectionWidth);
		highlight = [[UIView alloc] initWithFrame:CGRectMake(highlightX, 0, sectionWidth, self.frame.size.height)];
		[highlight setBackgroundColor:[UIColor colorWithRed:0.44 green:0.5 blue:0.85 alpha:0.2]]; // colorcolor
		[self addSubview:highlight];
		highlightedSection = sectionForPos;
	}
}

- (void) doSelectionForPostion:(CGPoint)position{
	int sectionForPos = [self sectionForPosition:position];
	if(sectionForPos >= 0 && sectionForPos < NUM_COLUMNS){
		[delegate columnSelected:sectionForPos];
		
	} 
}

-(void) highlightLineAtStartRow:(int)startRow startCol:(int)startCol endRow:(int)endRow endCol:(int)endCol{
	//this is to highlight a winning line
	int sectionWidth = (int)(self.frame.size.width / NUM_COLUMNS);
	int sectionHeight = (int)(self.frame.size.height / NUM_ROWS);
	int winLineStartX = (int)(startCol * sectionWidth) + (sectionWidth / 2) + LINE_OFFSET_X;
	int winLineStartY = (int)(self.frame.size.height - (startRow * sectionHeight)) - (sectionHeight / 2) + LINE_OFFSET_Y;
	int winLineEndX = (int)(endCol * sectionWidth) + (sectionWidth / 2) + LINE_OFFSET_X;
	int winLineEndY = (int)(self.frame.size.height - (endRow * sectionHeight)) - (sectionHeight / 2) + LINE_OFFSET_Y;
	
	[gameWinLine setStartX:winLineStartX];
	[gameWinLine setStartY:winLineStartY];
	[gameWinLine setEndX:winLineEndX];
	[gameWinLine setEndY:winLineEndY];
	[gameWinLine setNeedsDisplay];
	[self addSubview:gameWinLine];
}

#pragma mark -
#pragma mark pieceAnimation
-(void) dropPiece:(Player)player row:(int)row column:(int)column{
	// Audio
	if ( (row>0) && (row<7) ) { // row is 1..6
		[audio_row[row-1] play];
		NSLog(@"play sound %d",row);
	}

	// Graphics & Animation
	int pieceX = (int) (FIRST_HOLE_X_OFFSET + HOLE_X_SPACING * column);
	int pieceY = (int) (FIRST_HOLE_Y_OFFSET + HOLE_Y_SPACING * (NUM_ROWS - row));
	
	NSString *pieceName = nil;
	if(player == RED_PLAYER){
		pieceName = @"bump4pieceRedNew.png";
	} else if(player == BLACK_PLAYER){
		pieceName = @"bump4pieceBlackNew.png";
	} else {
		return;
	}
	UIImageView *newPiece = [[UIImageView alloc] initWithImage:[UIImage imageNamed:pieceName]];
	
	CGRect startFrame = CGRectMake(pieceX, 0, newPiece.frame.size.width, newPiece.frame.size.height);
	CGRect endFrame = CGRectMake(pieceX, pieceY, newPiece.frame.size.width, newPiece.frame.size.width);
	
	[newPiece setFrame:startFrame];
	[newPiece setTag:PIECE_TAG];
	
	//time to fall = sqrt(2h / g)
	//use UIViewAnimationCurveEaseIn to approximate acceleration of fall
	//asume the board is about 1/5 of a meter tall
	double h = ((double)pieceY / (self.frame.size.height)) * 0.2;
	NSTimeInterval duration = sqrt(2 * h / 9.8) * (0.3/0.203); // (0.5/0.203) is Dave Lieb fudge factor to make time longer.
	
	[self addSubview:newPiece];
	[self sendSubviewToBack:newPiece];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	//[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(dropPieceAnimationEnded)];
	[UIView setAnimationDuration:duration];
	[newPiece setFrame:endFrame];
	[UIView commitAnimations];
	[newPiece release];
}
	
#pragma mark -
#pragma mark UIResponder
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch * touch = [touches anyObject];
	[self updateHightlightForPostion:[touch locationInView:self]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch * touch = [touches anyObject];
	[self updateHightlightForPostion:[touch locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch * touch = [touches anyObject];
	[self doSelectionForPostion:[touch locationInView:self]];
	[self removeHighlight];
}

- (void)touchesCanceled:(NSSet *)touches withEvent:(UIEvent *)event{
	[self removeHighlight];
}
#pragma mark -

- (void)dealloc {
	for (int i=0;i<6; i++) [audio_row[i] release];
    [super dealloc];
}


@end
