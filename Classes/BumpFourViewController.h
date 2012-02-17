//
//  BumpFourViewController.h
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

#import <UIKit/UIKit.h>
#import "B4BoardView.h"
#import "GameBumpConnector.h"

@interface BumpFourViewController : UIViewController <UIAlertViewDelegate> {
	B4BoardModel *boardModel;
	B4BoardView *boardView;
	UILabel *statusLine;
	UIActivityIndicatorView *statusActivityView;
	UILabel *whosTurnLineLeft;
	UILabel *whosTurnLineRight;
	UIImageView *whosTurnIconLeft;
	UIImageView *whosTurnIconRight;
	UIImageView *whosTurnArrowLeft;	
	UIImageView *whosTurnArrowRight;	
	UIImageView *bumpFourLogo;	
	UIButton *bumpToConnectButton;
	UIButton *quitButton;
	NSMutableData *received_data;
	NSString *buttonUrl;
	
	Player localPlayer;
	Player turn;
	Player winner;
	NSString *tempStatusText;
	
	NSString *localPlayerName;
	NSString *remotePlayerName;
	
	UIAlertView *endOfGameAlert;
	
	UIView *startGameOverlay;
	
	GameBumpConnector *bumpConn;
}

@property (nonatomic, retain) IBOutlet  B4BoardView *boardView;
@property (nonatomic, retain) UILabel  *statusLine; // formerly was IBOutlet
@property (nonatomic, retain) UIActivityIndicatorView *statusActivityView; // formerly was IBOutlet

@property (nonatomic, retain) IBOutlet  UILabel *whosTurnLineLeft;
@property (nonatomic, retain) IBOutlet  UILabel *whosTurnLineRight;
@property (nonatomic, retain) IBOutlet  UIImageView *whosTurnIconLeft;
@property (nonatomic, retain) IBOutlet  UIImageView *whosTurnIconRight;
@property (nonatomic, retain) IBOutlet  UIImageView *whosTurnArrowLeft;
@property (nonatomic, retain) IBOutlet  UIImageView *whosTurnArrowRight;

@property (nonatomic, retain) IBOutlet  UIImageView *bumpFourLogo;
@property (nonatomic, retain) IBOutlet  UIButton *bumpToConnectButton;
@property (nonatomic, retain) IBOutlet  UIButton *quitButton;

@property (nonatomic, assign) Player localPlayer;
@property (nonatomic, assign) Player turn;
@property (nonatomic, copy) NSString *localPlayerName;
@property (nonatomic, copy) NSString *remotePlayerName;

@property (nonatomic, retain) GameBumpConnector *bumpConn;
-(void) applicationWillTerminate:(UIApplication *)application;
-(void) restartProgram;
-(void) startGame;
-(void) updateStatusLineWithText:(NSString *)text showSpinner:(Boolean)showSpinner animated:(Boolean)animated;
-(void) showMessage:(NSString *)message;

-(IBAction) startBumpButtonPress; 
-(IBAction) showQuitGameConfirmation;
@end

