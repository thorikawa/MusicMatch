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
  
  int count = 0;
    for (MPMediaItem *song in itemsFromGenericQuery) {
        NSString *songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        NSString *artistName = [song valueForProperty: MPMediaItemPropertyArtist];
        NSNumber *playCount = [song valueForProperty:MPMediaItemPropertyPlayCount];
        NSNumber *mediaType = [song valueForProperty:MPMediaItemPropertyMediaType];
        NSString *genre = [song valueForProperty:MPMediaItemPropertyGenre];
      if (NSNotFound != [genre rangeOfString:@"spoken" options:NSCaseInsensitiveSearch].location) {
        // skip spoken audio, such as language text or radio
        continue;
      }
      if (!(MPMediaTypeMusic && [mediaType intValue])) continue;
      if (artistName == nil) {
        NSLog(@"artistName is nil. title=%@", songTitle);
        continue;
      }
        
      NSLog (@"%@ - %@ -%@: %d", songTitle, artistName, genre, [playCount intValue]);
      NSNumber* num = [dict objectForKey:artistName];
      if (num == nil) num = [NSNumber numberWithInt:0];
      num = [NSNumber numberWithInt:[num intValue] + 1];
      [dict setObject:num forKey:artistName];
      count++;
    }
  
  NSMutableDictionary *weightDict = [[[NSMutableDictionary alloc] init] autorelease];
  for (NSString* key in dict) {
    NSNumber* num = [dict objectForKey:key];
    float weight = [num floatValue] / (float)count;
    [weightDict setObject:[NSNumber numberWithFloat:weight] forKey:key];
  }
  
    return weightDict;
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
  float fSimilarity = 0;
  NSMutableArray* artistWeightArray = [[[NSMutableArray alloc] init] autorelease];  
    for (NSString* key in otherDict) {
        NSNumber* otherNum = [otherDict objectForKey:key];
        NSNumber* myNum = [myDict objectForKey:key];
      if (myNum == nil) continue;
      
      float otherWeight = [otherNum floatValue];
      float myWeight = [myNum floatValue];
      // this is guaranteed in other library
      fSimilarity += myWeight;
      float artistWeight = (otherWeight+myWeight)/2.0;
      NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
      [data setObject:[NSNumber numberWithFloat:artistWeight] forKey:@"w"];
      [data setObject:key forKey:@"a"];
      [artistWeightArray addObject:data];
    }
  
  NSArray *sortedArray;
  sortedArray = [artistWeightArray sortedArrayUsingComparator:^(id a, id b) {
    NSDate *first = [(NSDictionary*)a objectForKey:@"w"];
    NSDate *second = [(NSDictionary*)b objectForKey:@"w"];
    return [first compare:second];
  }];
  
    int similarity = 100 * fSimilarity;
  int rank = MIN(3, [sortedArray count]);
    NSString* message = [NSString stringWithFormat:@"あなた達の相性は%dパーセントです。二人の共通アーティストは...", similarity, mostSimilarArtist];
  for (int i=0; i<rank; i++) {
    NSDictionary* dic = (NSDictionary*)[sortedArray objectAtIndex:i];
    NSString* s = [NSString stringWithFormat:@"\n%d位:%@", i+1, [dic objectForKey:@"a"]];
    message = [NSString stringWithFormat:@"%@%@", message, s];
  }
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
