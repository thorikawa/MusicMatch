//
//  BumpFourViewController.m
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

#import "BumpFourViewController.h"
#define END_OF_GAME_ALERT 101
#define QUIT_CONFIRM_ALERT 102
#define UPDATE_CHECK @"http://www.bumphome.com/check_for_update?appcode=com.bumptechnologies.BumpFour&version=1.01" // version 1.01

@implementation BumpFourViewController
@synthesize boardView, statusLine, statusActivityView, whosTurnLineLeft, whosTurnIconLeft, 
	whosTurnLineRight, whosTurnIconRight, bumpFourLogo, whosTurnArrowLeft, whosTurnArrowRight,  
	bumpConn, localPlayer, turn, localPlayerName, remotePlayerName, bumpToConnectButton, 
	quitButton;

- (void) updateStatusLineWithText:(NSString *)text showSpinner:(Boolean)showSpinner animated:(Boolean)animated{
	if(showSpinner){
		[statusActivityView startAnimating];
	} else {
		[statusActivityView stopAnimating];
	}
	
	if(animated){
		tempStatusText = [text copy];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(statusLineFadeOutDone)];
		[UIView setAnimationDuration:0.2];
		[statusLine setAlpha:0.0];
		[UIView commitAnimations];
	} else {
		[statusLine setText:text];	
	}
	
}

- (NSString *) playerName:(Player)p{
	if(p == localPlayer){
		return localPlayerName;
	} else {
		return remotePlayerName;
	}
}

- (void) statusLineFadeOutDone{
	//text faded out... now we fade back in and the text is updated
	[statusLine setText:tempStatusText];
	[tempStatusText release];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.2];
	[statusLine setAlpha:1.0];
	[UIView commitAnimations];	
}

- (void) updateWhosTurnLine{
	NSString *playerName = nil;
	
	playerName = [self playerName:RED_PLAYER];
	if (!playerName) {
		playerName = @"Red";
	}
	[whosTurnLineRight setText:[NSString stringWithString:playerName]];

	playerName = [self playerName:BLACK_PLAYER];
	if (!playerName) {
		playerName = @"Black";
	}
	[whosTurnLineLeft setText:[NSString stringWithString:playerName]];
	
	if (turn == RED_PLAYER) {
		[whosTurnIconLeft setImage:[UIImage imageNamed:@"bump4_whosemove_black.png"]];
		[whosTurnIconRight setImage:[UIImage imageNamed:@"bump4_whosemove_red_glow.png"]];
		[whosTurnArrowLeft setHidden:YES];
		[whosTurnArrowRight setHidden:NO];
	} else {
		[whosTurnIconLeft setImage:[UIImage imageNamed:@"bump4_whosemove_black_glow.png"]];
		[whosTurnIconRight setImage:[UIImage imageNamed:@"bump4_whosemove_red.png"]];
		[whosTurnArrowLeft setHidden:NO];
		[whosTurnArrowRight setHidden:YES];
	}
	
}

- (void) showMessage:(NSString *)message{
	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
	endOfGameAlert = [[UIAlertView alloc] initWithTitle:@"★結果★" message:message delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:nil, nil];
	endOfGameAlert.tag = END_OF_GAME_ALERT;
	[endOfGameAlert show];
}

- (void) showGameOverMessage:(NSString *)message{
	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
	endOfGameAlert = [[UIAlertView alloc] initWithTitle:@"Game Over" message:message delegate:self cancelButtonTitle:@"Disconnect" otherButtonTitles:@"Play Again", nil];
	endOfGameAlert.tag = END_OF_GAME_ALERT;
	[endOfGameAlert show];
}

- (IBAction) showQuitGameConfirmation{
	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
	endOfGameAlert = [[UIAlertView alloc] initWithTitle:@"End Game?" message:@"Are you sure you want to end game?" delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:@"Cancel", nil];
	endOfGameAlert.tag = QUIT_CONFIRM_ALERT;
	[endOfGameAlert show];
}

- (void) doGameOverSequence:(NSDictionary *)endDict{
	if(endDict != nil){
		[boardView setUserInteractionEnabled:NO];
		winner = [[endDict objectForKey:@"GAME_WINNER"] integerValue];
		if(winner == NOBODY_PLAYER){
			//game resulted in a tie
			[self performSelector:@selector(showGameOverMessage:) withObject:@"This round ended in a tie!" afterDelay:1.0];
		} else {
			
			NSArray *startIdx = [endDict objectForKey:@"GAME_WINNING_LINE_START"];
			NSArray *endIdx = [endDict objectForKey:@"GAME_WINNING_LINE_END"];
			int startRow = [[startIdx objectAtIndex:0] integerValue];
			int startCol = [[startIdx objectAtIndex:1] integerValue];
			int endRow = [[endIdx objectAtIndex:0] integerValue];
			int endCol = [[endIdx objectAtIndex:1] integerValue];
			
			[boardView highlightLineAtStartRow:startRow startCol:startCol endRow:endRow endCol:endCol];
			NSString *winnerName = [self playerName:winner];
			if (winner == localPlayer) {
				[self performSelector:@selector(showGameOverMessage:) withObject:[NSString stringWithFormat:@"You Win!!", winnerName] afterDelay:3.0];
				[boardView audioPlayWin];
			}
			else {
				[self performSelector:@selector(showGameOverMessage:) withObject:[NSString stringWithFormat:@"Sorry.  %@ won this round!", winnerName] afterDelay:3.0];
			}
		}
	}
}

- (void) showStartGameOverlay{
	if(startGameOverlay == nil){
		
		startGameOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default.png"]];
		[startGameOverlay setFrame:CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height+20)]; // 20 pixel compensation for status bar
		[self.view addSubview:startGameOverlay];
		
		[self performSelector:@selector(hideStartGameOverlay) withObject:nil afterDelay:1.0];
	}
}

- (void) overlayFadeOutDone{
	[startGameOverlay removeFromSuperview];
	[startGameOverlay release];
	startGameOverlay = nil;
}

- (void) hideStartGameOverlay{
	if(startGameOverlay != nil){
		if([startGameOverlay superview]){
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(overlayFadeOutDone)];
			[UIView setAnimationDuration:0.3];
			[startGameOverlay setAlpha:0.0];
			[UIView commitAnimations];
		}
	}
}

- (void) resetGameState{
	[statusActivityView setHidesWhenStopped:YES];
	[statusActivityView stopAnimating];
	turn = RED_PLAYER;
	winner = NOBODY_PLAYER;
	//[self updateWhosTurnLine];
	[whosTurnLineLeft setText:@""];
	[whosTurnLineRight setText:@""];
	[whosTurnIconLeft setHidden:YES];
	[whosTurnIconRight setHidden:YES];
	[whosTurnArrowLeft setHidden:YES];
	[whosTurnArrowRight setHidden:YES];
	[self updateStatusLineWithText:@"" showSpinner:NO animated:NO];
	[boardView resetBoardView];
	[boardModel resetBoard];
}

- (void) restartProgram{
	[endOfGameAlert dismissWithClickedButtonIndex:-1 animated:NO];
	[self resetGameState];
	[self updateStatusLineWithText:@"Tap \"Bump to play a friend\" to start." showSpinner:NO animated:NO];
	[whosTurnLineLeft setText:@""];
	[whosTurnLineRight setText:@""];
	[whosTurnIconLeft setHidden:YES];
	[whosTurnIconRight setHidden:YES];
	[whosTurnArrowLeft setHidden:YES];
	[whosTurnArrowRight setHidden:YES];
	[bumpFourLogo setHidden:NO];
	[quitButton setHidden:YES];
	[bumpToConnectButton setHidden:NO];
	[boardView setUserInteractionEnabled:NO];
}

-(Boolean) myTurn{
	return turn == localPlayer;
}

-(void) startTurn{
	[self updateWhosTurnLine];
	if([self myTurn]){
		[boardView setUserInteractionEnabled:YES];
		[self updateStatusLineWithText:@"It's your move!" showSpinner:NO animated:NO];
	} else {
		[boardView setUserInteractionEnabled:NO];
		[self updateStatusLineWithText:@"Waiting for other player to move." showSpinner:YES animated:NO];		
	}
}

-(void) startGame{
	[whosTurnIconLeft setHidden:NO];
	[whosTurnIconRight setHidden:NO];
	[whosTurnArrowLeft setHidden:YES];
	[whosTurnArrowRight setHidden:YES];
	[bumpFourLogo setHidden:YES];
	[quitButton setHidden:NO];
	[bumpToConnectButton setHidden:YES];
	[self startTurn];
}

-(IBAction) startBumpButtonPress{
    NSLog(@"startBump");
	self.bumpConn = [[[GameBumpConnector alloc] init] autorelease];	
	[bumpConn setBumpFourGame:self];
	[bumpConn startBump];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (alertView.tag == END_OF_GAME_ALERT) {
		switch (buttonIndex) {
			case 0: //Quit Pressed
				NSLog(@"Quit Pressed");
				[bumpConn stopBump];
				[self restartProgram];
				break;
			case 1: //Play Again Pressed
				NSLog(@"Play Again Pressed");
				[self resetGameState];
				//[self startGame];
				//instead of starting the game here, let's go through the dice rolling again (via bumpDidConnect), this allows the first player to change between games
				// and also stops users from getting out of sync because
				// they both have to respond with die rolls before play resumes.
				[bumpConn startGame];
				break;
			default:
				break;
		}
	} 
	if (alertView.tag == QUIT_CONFIRM_ALERT) {
		switch (buttonIndex) {
			case 0: //Quit Pressed
				NSLog(@"Quit Pressed");
				[boardView audioPlayEnd];
				[bumpConn stopBump];
				[self restartProgram];
				break;
			case 1: //Cancel Pressed
				NSLog(@"Cancel Pressed");
				break;
			default:
				break;
		}
	}	

	if(endOfGameAlert != nil){
		[endOfGameAlert release];
		endOfGameAlert = nil;
	}
}
#pragma mark -

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	boardModel = [[B4BoardModel alloc] init];
	[self restartProgram];
	[self showStartGameOverlay];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.boardView = nil;
	self.statusLine = nil;
	self.statusActivityView = nil;
	self.whosTurnLineLeft = nil;
	self.whosTurnIconLeft = nil;
	self.bumpConn = nil;
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
//}

-(void)applicationWillTerminate:(UIApplication *)application{
	[bumpConn stopBump];
}


- (void)dealloc {
    [super dealloc];
}

@end
