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


#import "BumpConnector.h"
#import "MainViewController.h"


@implementation BumpConnector
@synthesize mainViewController;
- (id) init{
	if(self = [super init]){
		bumpObject = [BumpAPI sharedInstance];
		bumpsound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sound_bump_tap" ofType:@"aif" inDirectory:@"/"]] error:NULL];
		[bumpsound prepareToPlay];
	}
	return self;
}

-(void) configBump{
	[bumpObject configAPIKey:@"f2c072a5cbf24c5cb26b0be2e24da190"];//put your api key here. Get an api key from http://bu.mp
	[bumpObject configDelegate:self];
	[bumpObject configParentView:mainViewController.view];
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

// for Debug -- prints contents of NSDictionary
-(void)printDict:(NSDictionary *)ddict {
	NSLog(@"---printing Dictionary---");
	NSArray *keys = [ddict allKeys];
	for (id key in keys) {
		NSLog(@"   key = %@     value = %@",key,[ddict objectForKey:key]);
	}	
}

-(NSDictionary*) musicInfoDictionary{
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] init] autorelease];
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSLog(@"Logging items from a generic query...");
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *artistName = [song valueForProperty: MPMediaItemPropertyArtist];
        NSNumber *playCount = [song valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *mediaType = [song valueForProperty:MPMediaItemPropertyMediaType];
        NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];
        if (NSNotFound != [genre rangeOfString:@"spoken" options:NSCaseInsensitiveSearch].location) continue;
        if (!(MPMediaTypeMusic && [mediaType intValue])) continue;
        
        NSLog (@"%@ - %@ -%@: %d", songTitle, artistName, genre, [playCount intValue]);
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
- (void) startGame {
	//The first thing we need to do upon succesful connection is to decide which player will go first.
	//We do this by having both players send a dice roll between 1 and 1000, the player with the higher roll
	//will becom the first player (red).
	//If player's rolls are equal, both players will roll again until a player can be determined.
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
	NSDictionary *otherDict = [NSKeyedUnarchiver unarchiveObjectWithData:chunk];
	[self printDict:otherDict];
	
	//otherDict no contains an Identical dictionary to the one that the other user sent us
	
    NSDictionary* myDict = [self musicInfoDictionary];
    [self printDict:myDict];
    
    //calculate similarity of two
    NSString* mostSimilarArtist;
    int mostSimilarCount = 0;
    int totalSimilarCount = 0;
    int sum1 = 0;
    int sum2 = 0;
    for (NSString* key in otherDict) {
        NSNumber* num1 = [otherDict objectForKey:key];
        NSNumber* num2 = [myDict objectForKey:key];
        int count1 = [num1 intValue];
        int count2 = [num2 intValue];
        sum1 += count1;
        sum2 += count2;
        int similar = MIN(count1, count2);
        if (similar > mostSimilarCount) {
            mostSimilarArtist = key;
            mostSimilarCount = similar;
        }
        totalSimilarCount += similar;
    }
    int similarity = 100 * (float) totalSimilarCount / (float) MIN(sum1, sum2);
    
    NSString* message = [NSString stringWithFormat:@"あなた達の相性は%dパーセントです。二人の共通アーティストは%@です。", similarity, mostSimilarArtist];
    [mainViewController showMessage:message];
		
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
