//
//  GameBumpConnector.h
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

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BumpAPI.h"
#import "Bumper.h"

@class MainViewController;

@interface BumpConnector : NSObject <BumpAPIDelegate> {
	MainViewController *mainViewController;
	BumpAPI *bumpObject;
	AVAudioPlayer *bumpsound;
}

@property (nonatomic, assign) MainViewController *mainViewController;

- (void) startGame;
- (void) startBump;
- (void) stopBump;
@end
