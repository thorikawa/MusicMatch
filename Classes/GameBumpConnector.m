//
//  GameBumpConnector.m
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

//This is a simple example of how to use the Bump API.
// All methods found under the tag: #pragma mark BumpDelegate methods


#import "GameBumpConnector.h"
#import "BumpFourViewController.h"


@implementation GameBumpConnector
@synthesize bumpFourGame;
- (id) init{
	if(self = [super init]){
		myRollNumber = 0;
		opponentRollNumber = -1;
		bumpObject = [BumpAPI sharedInstance];
		bumpsound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_bump_tap" ofType:@"aif" inDirectory:@"/"]] error:NULL];
		[bumpsound prepareToPlay];
	}
	return self;
}

-(void) configBump{
	[bumpObject configAPIKey:@"f2c072a5cbf24c5cb26b0be2e24da190"];//put your api key here. Get an api key from http://bu.mp
	[bumpObject configDelegate:self];
	[bumpObject configParentView:bumpFourGame.view];
	[bumpObject configActionMessage:@"Bump with another BumpFour player to start game."];
}

- (void) startBump{
	[self configBump];
	[bumpObject requestSession];
}

- (void) stopBump{
	[bumpObject endSession];
}

#pragma mark -
#pragma mark Private Methods
-(void) determineFirstPlayer{	
	//if either of the rollNumbers haven't been set yet we can't determine yet
	NSLog(@"===>attempt to determine first player.");
	if(myRollNumber == -1 || opponentRollNumber == -1){
		NSLog(@"===>don't have rolls for both players. numtimes rolled are me:%d other:%d", myRollNumber, opponentRollNumber);	
		return;
	}
	//make sure we are on the same roll as the opponent
	if(myRollNumber == opponentRollNumber){
		if(opponentRoll == myRoll){
			//if it's the same both players will roll again
			NSLog(@"===>we rolled the same thing, roll again me:%d other:%d", myRoll, opponentRoll);	
			[self performSelector:@selector(sendMyDieRoll) withObject:nil];
		} else if(opponentRoll >= myRoll) {
			NSLog(@"===>Opponent got the high roll, roll again me:%d other:%d", myRoll, opponentRoll);
			[bumpFourGame setLocalPlayer:BLACK_PLAYER];
			[bumpFourGame startGame];
			NSLog(@"Local player is BLACK!!");
		} else {
			NSLog(@"===>I got the high roll, roll again me:%d other:%d", myRoll, opponentRoll);
			[bumpFourGame setLocalPlayer:RED_PLAYER];
			[bumpFourGame startGame];
			NSLog(@"Local player is RED!!");
		}
	} else {
		//Wait until we have both players rolls for the same attempt. i.e. do nothing.
		NSLog(@"===>We're on differen't roll numbers wait for next time. numtimes rolled are me:%d other:%d", myRollNumber, opponentRollNumber);
	}
}

// for Debug -- prints contents of NSDictionary
-(void)printDict:(NSDictionary *)ddict {
	NSLog(@"---printing Dictionary---");
	NSArray *keys = [ddict allKeys];
	for (id key in keys) {
		NSLog(@"   key = %@     value = %@",key,[ddict objectForKey:key]);
	}	
}

-(void) sendMyDieRoll{
	NSMutableDictionary *moveDict = [[NSMutableDictionary alloc] initWithCapacity:5];
	[moveDict setObject:[[bumpObject me] userName]  forKey:@"USER_ID"];
	[moveDict setObject:@"DETERMINE_PLAYER_1"  forKey:@"GAME_ACTION"];
	[moveDict setObject:[NSString stringWithFormat:@"%d", ++myRollNumber]  forKey:@"DICE_ROLL_TRY_NUM"];
	myRoll = arc4random() % 1000;
	[moveDict setObject:[NSString stringWithFormat:@"%d", myRoll]  forKey:@"DICE_ROLL_VALUE"];
	
	NSData *moveChunk = [NSKeyedArchiver archivedDataWithRootObject:moveDict];
	//[self printDict:moveDict];
	[moveDict release];
	packetsAttempted++;
	[bumpObject sendData:moveChunk];

	
	//call this here incase we are late and already have the opponnent roll.
	[self determineFirstPlayer];
}

-(NSDictionary*) musicInfoDictionary{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *artistName = [song valueForProperty: MPMediaItemPropertyArtist];
        NSLog (@"%@ - %@", songTitle, artistName);
        NSNumber* num = [dict objectForKey:artistName];
        if (num == nil) num = [NSNumber numberWithInt:0];
        num = [NSNumber numberWithInt:[num intValue] + 1];
        if (artistName == nil) {
            NSLog(@"artistName is nil. title=%@", songTitle);
            continue;
        }
        [dict setObject:num forKey:artistName];
    }
    return dict;
}

-(void) sendMusicInfo{
    NSDictionary* dict = [self musicInfoDictionary];
    NSData *moveChunk = [NSKeyedArchiver archivedDataWithRootObject:dict];
	[self printDict:dict];
	[bumpObject sendData:moveChunk];
}

#pragma mark -
#pragma mark Public Methods
- (void) sendGameMove:(int)column{
	if(bumpFourGame.turn == bumpFourGame.localPlayer){ //if it is the local players turn send the move.
		
		//Create a dictionary describing the move to the other client.
		//We chose to send a dictionary for our communications for this example,
		//But you can use any type of data you like, as long as you convert it to an NSData object.
		NSMutableDictionary *moveDict = [[NSMutableDictionary alloc] initWithCapacity:5];
		[moveDict setObject:[[bumpObject me] userName]  forKey:@"USER_ID"];
		//Tell the other client the action we wish to perform is a "MOVE" so it knows what to do with this data.
		[moveDict setObject:@"MOVE"  forKey:@"GAME_ACTION"];
		//Tell the other client what column we made a move into.
		[moveDict setObject:[NSString stringWithFormat:@"%d", column]  forKey:@"MOVED_COLUMN"];
		
		//Now we need to package our move dictionary up into an NSData object so we can send it up to Bump.
		//We'll do that with with an NSKeyedArchiver.
		NSData *moveChunk = [NSKeyedArchiver archivedDataWithRootObject:moveDict];
		//[self printDict:moveDict];
		[moveDict release];
		
		//Calling send will have bump send the data up to the other user's mailbox.
		//The other user will get a bumpDataReceived: callback with an identical NSData* chunk shortly.
		packetsAttempted++;
		[bumpObject sendData:moveChunk];
	}
}

- (void) startGame {
	//The first thing we need to do upon succesful connection is to decide which player will go first.
	//We do this by having both players send a dice roll between 1 and 1000, the player with the higher roll
	//will becom the first player (red).
	//If player's rolls are equal, both players will roll again until a player can be determined.
	myRollNumber = 0;
	[bumpFourGame setLocalPlayerName:[[bumpObject me] userName]];
	[bumpFourGame setRemotePlayerName:[[bumpObject otherBumper] userName]];
	[bumpFourGame updateStatusLineWithText:@"Determining first player..." showSpinner:YES animated:YES];
    NSLog(@"username=%@", [[bumpObject me] userName]);
	[self sendMusicInfo];
}
#pragma mark Utility
-(void) quickAlert:(NSString *)titleText msgText:(NSString *)msgText{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleText message:msgText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark BumpAPIDelegate methods

- (void) bumpDataReceived:(NSData *)chunk{
    NSLog(@"received");
	//The chunk was packaged by the other user using an NSKeyedArchiver, so we unpackage it here with our NSKeyedUnArchiver
	NSDictionary *responseDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	[self printDict:responseDictionary];
	
	//responseDictionary no contains an Identical dictionary to the one that the other user sent us
	//NSString *userName = [responseDictionary objectForKey:@"USER_ID"];
	//NSString *gameAction = [responseDictionary objectForKey:@"GAME_ACTION"];
	
	//NSLog(@"user name and action are %@, %@", userName, gameAction);
	
	//if([gameAction isEqualToString:@"DETERMINE_PLAYER_1"]){
    NSDictionary* myDict = [self musicInfoDictionary];
    [self printDict:myDict];
    
    //calculate similarity of two
    NSString* mostSimilarArtist;
    int mostSimilarCount = 0;
    int totalSimilarCount = 0;
    int sum1 = 0;
    int sum2 = 0;
    for (NSString* key in responseDictionary) {
        NSNumber* num1 = [responseDictionary objectForKey:key];
        NSNumber* num2 = [myDict objectForKey:key];
        int count1 = [num1 intValue];
        int count2 = [num2 intValue];
        sum1 += count1;
        sum2 += count2;
        int similar = MIN(count1, count2);
        if (similar > mostSimilarCount) {
            mostSimilarArtist = key;
        }
        totalSimilarCount += similar;
    }
    float similarity = (float) totalSimilarCount / (float) MIN(sum1, sum2);
    
    NSString* message = [NSString stringWithFormat:@"あなた達の相性は%fパーセントです。二人の共通アーティストは%@です。", similarity, mostSimilarArtist];
    [bumpFourGame showMessage:message];
    
	//}
		
}

- (void) bumpSessionStartedWith:(Bumper*)otherBumper{
    NSLog(@"session start");
	[self startGame];
}

- (void) bumpSessionEnded:(BumpSessionEndReason)reason {
    NSLog(@"session end");
	NSString *alertText;
	switch (reason) {
		case END_OTHER_USER_QUIT:
			alertText = @"Other user has quit the game.";
			break;
		case END_LOST_NET:
			alertText = @"Connection to Bump server was lost.";
			break;
		case END_OTHER_USER_LOST:
			alertText = @"Connection to other user was lost.";
			break;
		case END_USER_QUIT:
			alertText = @"You have been disconnected.";
			break;
		default:
			alertText = @"You have been disconnected.";
			break;
	}
	
	if(reason != END_USER_QUIT){ 
		//if the local user initiated the quit,restarting the app is already being handled
		//other wise we'll restart here
		[bumpFourGame restartProgram];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) bumpSessionFailedToStart:(BumpSessionStartFailedReason)reason {
	NSLog(@"session fail to start");
	NSString *alertText;
	switch (reason) {
		case FAIL_NETWORK_UNAVAILABLE:
			alertText = @"Please check your network settings and try again.";
			break;
		case FAIL_INVALID_AUTHORIZATION:
			//the user should never see this, since we'll pass in the correct API auth strings.
			//just for debug.
			alertText = @"Failed to connect to the Bump service. Auth error.";
			break;
		default:
			alertText = @"Failed to connect to the Bump service.";
			break;
	}
	
	[bumpFourGame restartProgram];
	if(reason != FAIL_USER_CANCELED){
		//if the user canceled they know it and they don't need a popup.
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failed" message:alertText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

#pragma mark -
-(void) dealloc{
	[bumpsound release];
	//[bumpObject release];
	[super dealloc];
}

@end
